package eu.ohmrun.jali;

import stx.arw.Arrowlet.ArrowletApi;
import stx.parse.jali.term.Id;
import stx.parse.jali.term.Stash;
import stx.parse.jali.term.Memo;
import stx.parse.jali.term.Tag;
import stx.parse.jali.term.Get;


class GrammarApi<T> extends haxe.ds.StringMap<Parser<T,Lang<T>>> implements ParserApi<T,Lang<T>>{
  public var tag                            : Option<String>;
  public var id(default,null)               : Pos;
  
  public var uid(default,null)              : Int;

  public var rest(default,null):Map<String,Grammar<T>>;
  public var name(default,null):String;
  override public function new(name,rest:Map<String,Grammar<T>>,?id:Pos){
    this.name = name;
    this.rest = rest;
    this.id   = id;
    this.tag  = Some("Jali");
    super();
  }
  function def(name:String):Parser<T,Lang<T>>{
    throw 'undefined: "$name"';
    return new Failed('no handler found for grammar: "$name"').asParser();
  }
  public function lazy(seed:Lang<T>):Parser<T,Lang<T>>{
    return new LAnon(apply.bind(seed)).asParser();
  }
  public function apply(seed:Lang<T>):Parser<T,Lang<T>>{
    return switch seed {
      case One              : new Succeed(seed).asParser();
      case Lit(e)           : new Succeed(Lit(e)).asParser();
      case Mem(e)           : new Memo(lazy(e)).asParser();
      case App(name,null)   : of(name);
      case App(name,args)   : new Stash(of(name),args).asParser();
      case Tag(name,e)      : new Tag(name,apply(e)).asParser();
      case Seq(l, r)        : lazy(l).and(lazy(r)).then(__.decouple(seq));// until Lit? or fail if lit not first?
      case Alt(l, r)        : lazy(l).or(lazy(r));
      case Rep(e)           : lazy(e).many().then(arr -> arr.lfold(Lang.then,Lit(Empty)));
      case Opt(e)           : lazy(e).option().then(opt -> opt.defv(seed));
      case Get(e0,e1)       : new Get(lazy(e0),e1).asParser();
      case Sip(e)           : new Get(lazy(e),Lit(Empty)).asParser();
      case Def(name,lang)   : 
        var grammar = new Grammar(name);
        for(key => val in lang){
          grammar.set(key,grammar.apply(val));
        }
        grammar.of("main");
    };
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
    var a = __.option(this.get(key));
    var b = a.def(def.bind(key));
    return b;
  }
  public function applyII(ipt:Input<T>,cont:Terminal<ParseResult<T,Lang<T>>,Noise>):Work{
   return doApplyII(ipt,cont);
  }
  private function doApplyII(ipt:Input<T>,cont:Terminal<ParseResult<T,Lang<T>>,Noise>):Work{
    return this.of('main').applyII(ipt,cont);
  }
  public function asArrowletDef():ArrowletDef<Input<T>,ParseResult<T,Lang<T>>,Noise>{
    return this;
  }
  public final inline function definition():Class<Dynamic>{
    return Type.getClass(this);
  }
  public final inline function identifier():String{
    return Type.getClassName(definition());
  }
  public function asParser():Parser<T,Lang<T>>{
    return new Parser(this);
  }
}

@:forward abstract Grammar<T>(GrammarApi<T>) from GrammarApi<T> to GrammarApi<T>{
  public function new(name:String) this = new GrammarApi(name,new Map());

  public function fromExprs(map:StdMap<String,Lang<T>>){
    for( key => val in map){
      this.set(key,val.toParser(self));
    }
    return this;
  }

  public function prj():GrammarApi<T> return this;
  
  private var self(get,never):Grammar<T>;
  private function get_self():Grammar<T> return this;
}
class GrammarLift{
  //static public function id()
}