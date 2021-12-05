package eu.ohmrun.jali;

import haxe.Constraints.IMap;
import stx.parse.jali.term.*;

class GrammarCls<T> extends ParserCls<T,Lang<T>> implements IMap<String,Parser<T,Lang<T>>>{
  private var map: StringMap<Parser<T,Lang<T>>>;
  public var rest(default,null):Map<String,Grammar<T>>;
  public var label(default,null):String;

  override public function new(label,?rest:Map<String,Grammar<T>>,?map:StringMap<Parser<T,Lang<T>>>,?pos:Pos){
    this.label  = label;
    this.rest   = rest;
    this.map    = __.option(map).def(()->(new StringMap():StringMap<Parser<T,Lang<T>>>));
    this.pos    = pos;
    this.tag    = Some("Jali");
    super();
  }
  function def(name:String):Parser<T,Lang<T>>{
    throw 'undefined: "$name"';
    return new Failed('no handler found for grammar: "$name"').asParser();
  }
  public function lazy(seed:Lang<T>):Parser<T,Lang<T>>{
    return new LAnon(produce.bind(seed)).asParser();
  }
  public function produce(seed:Lang<T>):Parser<T,Lang<T>>{
    return switch seed {
      case One              : new Succeed(seed).asParser();
      case Lit(e)           : new Succeed(Lit(e)).asParser();
      case Mem(e)           : new Memo(lazy(e)).asParser();
      case App(name,null)   : of(name);
      case App(name,args)   : new Stash(of(name),args).asParser();
      case Tag(name,e)      : new Tag(name,produce(e)).asParser();
      case Seq(l, r)        : lazy(l).and(lazy(r)).then(__.decouple(seq));// until Lit? or fail if lit not first?
      case Alt(l, r)        : lazy(l).or(lazy(r));
      case Rep(e)           : lazy(e).many().then(arr -> arr.lfold(Lang.then,Lit(Empty)));
      case Opt(e)           : lazy(e).option().then(opt -> opt.defv(seed));
      case Get(e0,e1)       : new Get(lazy(e0),e1).asParser();
      case Sip(e)           : new Get(lazy(e),Lit(Empty)).asParser();
      // case Def(name,lang)   : 
      //   var grammar = new Grammar(name);
      //   for(key => val in lang){
      //     grammar.set(key,grammar.produce(val));
      //   }
      //   grammar.of("main");
    };
  }
  public function keyValueIterator(){
    return this.map.keyValueIterator();
  }
  public function iterator(){
    return this.map.iterator();
  }
  public function seq(l:Lang<T>,r:Lang<T>):Lang<T>{
    return switch([l,r]){
      case [Lit(Empty),r]   : r;
      case [l,Lit(Empty)]   : l;
      case [Lit(l),Lit(r)]  : Lit(Group(Cons(l,Cons(r,Nil))));
      default               : Seq(l,r);
    }
  }
  public function alt(l:Lang<T>,r:Lang<T>):Lang<T>{
    return switch([l,r]){
      case [Lit(l),Lit(r)]  : Lit(Group(Cons(l,Cons(r,Nil))));
      case [One,r]          : r;
      default               : Alt(l,r);
    }
  }
  public function of(key:String):Parser<T,Lang<T>>{
    var a = __.option(map.get(key));
    var b = a.def(def.bind(key));
    return b;
  }
  public function defer(ipt:ParseInput<T>,cont:Terminal<ParseResult<T,Lang<T>>,Noise>):Work{
    return this.of('main').defer(ipt,cont);
  }
  public inline function get(key:String){
    return this.map.get(key);
  }
  public inline function set(key:String,val:Parser<T,Lang<T>>){
    this.map.set(key,val);
  }
  public inline function exists(key:String){
    return this.map.exists(key);
  }
  public function copy(){
    var next_map = new Map();
    for(k => v in this){
      next_map.set(k,v);
    }
    return new GrammarCls(this.label,rest,next_map,pos);
  }
  public function clear(){
    this.map.clear();
  }
  public function keys(){
    return this.map.keys();
  }
  public function remove(str:String):Bool{
    return this.map.remove(str);
  }
}