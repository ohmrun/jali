package jali.pack;

import jali.head.data.Lang in LangT;

abstract Lang<T>(LangT<T>) from LangT<T> to LangT<T>{
  public function new(self) this = self;
  static public function lift<T>(self:LangT<T>):Lang<T> return new Lang(self);
  //TODO hmm?
  public function snoc(that:Lang<T>):Lang<T>{
    return switch([this,that]){
      case [Lit(e0),Lit(e1)] : Lit(e0.both(e1));
      default                : Seq(this,that);
    }
  }
  static public function then<T>(thiz:Lang<T>,that:Lang<T>):Lang<T> return thiz.snoc(that);

  public function prj():LangT<T> return this;
  private var self(get,never):Lang<T>;
  private function get_self():Lang<T> return lift(this);

  public function alt(arr:Array<Lang<T>>):Lang<T>       return jali.Lift.alts([self].ds().concat(arr));
  public function or(e1:Lang<T>):Lang<T>                return alt([e1]);
  public function seq(arr:Array<Lang<T>>):Lang<T>       return jali.Lift.seqs([self].ds().concat(arr));
  public function and(expr:Lang<T>):Lang<T>             return seq([expr]);
  public function rep():Lang<T>                         return Rep(this);
  public function rep1():Lang<T>                        return Seq(this,Rep(this));
  public function opt():Lang<T>                         return Opt(this);
  public function mem():Lang<T>                         return Mem(this);
  public function tag(str):Lang<T>                      return Tag(str,this);

  public function toParser(grammar:Grammar<T>):Parser<T,Lang<T>>{
    return new LAnon(grammar.apply.bind(this)).asParser();
  }
  static public function mod<T>(fn:Lang<T> -> Lang<T>,self:LangT<T>):Lang<T>{
    var f = mod.bind(fn);
    return fn(switch self {
      case One              : One;
      case App(name, args)  : App(name,args);
      case Tag(name, val)   : Tag(name,f(val));
      case Lit(e)           : Lit(e);
      case Seq(l, r)        : Seq(f(l),f(r));
      case Rep(e)           : Rep(f(e));
      case Alt(l, r)        : Alt(f(l),f(r));
      case Opt(e)           : Opt(f(e));
      case Mem(e)           : Mem(f(e));
    });
  }
  static public function fold<T,Z>(
    one:Void->Z,
    app:String->Z->Z,
    tag:String->Z->Z,
    lit:Z->Z,
    seq:Z->Z->Z,
    rep:Z->Z,
    alt:Z->Z->Z,
    opt:Z->Z,
    mem:Z->Z,

    term: Term<T> -> Z,
    v:LangT<T>
  ){
    var sub = fold.bind(one,app,tag,lit,seq,rep,alt,opt,mem,term);
    return switch v {
      case One              : one();
      case App(name, args)  : app(name,term(args));
      case Tag(name, val)   : tag(name,sub(val));
      case Lit(e)           : lit(term(e));
      case Seq(l, r)        : seq(sub(l),sub(r));
      case Rep(e)           : rep(sub(e));
      case Alt(l, r)        : alt(sub(l),sub(r));
      case Opt(e)           : opt(sub(e));
      case Mem(e)           : mem(sub(e));
    }
  }
  public function toString(){
    return switch this {
      case One              : '.';
      case App(name, args)  : 
        var arg = 
          __.option(args)
            .map(_ -> _.toStringCompact())
            .map(_ -> ' ($_)')
            .defv('');
      '$name$arg';
      case Tag(name, val)   : '#$name ${val.toString()}';
      case Lit(e)           : 'e.toString()';
      case Seq(l, r)        : '$l $r';
      case Rep(e)           : '${e}*';
      case Alt(l, r)        : '$l | $r';
      case Opt(e)           : '${e}?';
      case Mem(e)           : '@${e}';
    }
  }
}