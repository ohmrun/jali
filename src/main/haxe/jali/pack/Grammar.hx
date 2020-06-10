package jali.pack;

import stx.parse.jali.term.Stash;
import stx.parse.jali.term.Memo;
import stx.parse.jali.term.Tag;


class GrammarApi<T> extends haxe.ds.StringMap<Parser<T,Lang<T>>>{
  public var name(default,null):String;
  override public function new(name){
    this.name = name;
    super();
  }
  function def(name:String):Parser<T,Lang<T>>{
    return new Failed('no handler found for grammar: "$name"').asParser();
  }
  function lazy(seed:Lang<T>):Parser<T,Lang<T>>{
    return new LAnon(apply.bind(seed)).asParser();
  }
  public function apply(seed:Lang<T>):Parser<T,Lang<T>>{
    return switch seed {
      case One              : new Succeed(seed).asParser();
      case Lit(e)           : new Succeed(Lit(e)).asParser();
      case Mem(e)           : new Memo(e.toParser(this)).asParser();
      case App(name,args)   : new Stash(of(name),args).asParser();
      case Tag(name,e)      : new Tag(name,apply(e)).asParser();
      case Seq(l, r)        : lazy(l).and(lazy(r)).then(__.decouple(Seq));// until Lit? or fail if lit not first?
      case Alt(l, r)        : lazy(l).or(lazy(r));
      case Rep(e)           : lazy(e).many().then(arr -> arr.lfold(Lang.then,Lit(Empty)));
      case Opt(e)           : lazy(e).option().then(opt -> opt.defv(seed));
    };
  }
function seq(l:Lang<T>,r:Lang<T>):Lang<T>{
    return switch([l,r]){
      case [Lit(l),Lit(r)]  : Lit(Group(Cons(l,Cons(r,Nil))));
      default               : Seq(l,r);
    }
  }
  public function of(key:String):Parser<T,Lang<T>>{
    var a = __.option(this.get(key));
    var b = a.def(def.bind(key));
    return b;
  }
  public function parse(ipt:Input<T>):ParseResult<T,Lang<T>>{
    return this.of('main').parse(ipt);
  }
}

@:forward abstract Grammar<T>(GrammarApi<T>) from GrammarApi<T> to GrammarApi<T>{
  public function new(name:String) this = new GrammarApi(name);

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