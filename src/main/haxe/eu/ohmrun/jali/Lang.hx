package eu.ohmrun.jali;

enum LangSum<T>{
  
  App(name:String,?args:Expr<T>);
  Tag(name:String,val:Lang<T>);
  
  One;//what comes in goes out
  Lit(e:Expr<T>);//replace input with this

  Seq(l:Lang<T>,r:Lang<T>);
  Alt(l:Lang<T>,r:Lang<T>);

  Rep(e:Lang<T>);//+
  Opt(e:Lang<T>);//?
  //* == Opt(Rep(_))

  Mem(e:Lang<T>);//recursive rule

  //Not?
  //Has(e:Term<T>,o);//?if else?


  //Put(name:String,val:Lang<T>);?//put in the symbol table
  Get(e:Lang<T>,res:Lang<T>);//parse the left and produce the right
  //Use?
  Sip(e:Lang<T>);//swallow the result

  //Def(name:String,lang:Map<String,Lang<T>>);
}

abstract Lang<T>(LangSum<T>) from LangSum<T> to LangSum<T>{
  public function new(self) this = self;
  static public function lift<T>(self:LangSum<T>):Lang<T> return new Lang(self);
  
  public function snoc(that:Lang<T>):Lang<T>{
    return switch([this,that]){
      case [Lit(e0),Lit(e1)] : Lit(Group(Cons(e0,Cons(e1,Nil))));
      default                : Seq(this,that);
    }
  }
  static public function then<T>(thiz:Lang<T>,that:Lang<T>):Lang<T> return thiz.snoc(that);

  public function prj():LangSum<T> return this;
  private var self(get,never):Lang<T>;
  private function get_self():Lang<T> return lift(this);

  public function alt(arr:Array<Lang<T>>):Lang<T>       return LiftJali.alts([self].concat(arr));
  public function or(e1:Lang<T>):Lang<T>                return alt([e1]);
  public function seq(arr:Array<Lang<T>>):Lang<T>       return LiftJali.seqs([self].concat(arr));
  public function and(expr:Lang<T>):Lang<T>             return seq([expr]);
  public function rep():Lang<T>                         return Rep(this);
  public function rep1():Lang<T>                        return Seq(this,Rep(this));
  public function opt():Lang<T>                         return Opt(this);
  public function mem():Lang<T>                         return Mem(this);
  public function tag(str):Lang<T>                      return Tag(str,this);

  public function toParser(grammar:Grammar<T>):Parser<T,Lang<T>>{
    return new LAnon(grammar.produce.bind(this)).asParser();
  }
  static public function mod<T>(fn:Lang<T> -> Lang<T>,self:LangSum<T>):Lang<T>{
    var f = mod.bind(fn);
    return fn(switch self {
      case One              : One;
      case Get(e0,e1)       : Get(f(e0),f(e1));
      case App(name, args)  : App(name,args);
      case Tag(name, val)   : Tag(name,f(val));
      case Lit(e)           : Lit(e);
      case Seq(l, r)        : Seq(f(l),f(r));
      case Rep(e)           : Rep(f(e));
      case Alt(l, r)        : Alt(f(l),f(r));
      case Opt(e)           : Opt(f(e));
      case Mem(e)           : Mem(f(e));
      case Sip(e)           : Sip(f(e));
      //case Def(name,lang)   : Def(name,lang.copy().mod(fn));
    });
  }
  /*
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
    get:Z->Z->Z,
    sip:
    term: Expr<T> -> Z,
    v:LangSum<T>
  ){
    var sub = fold.bind(one,app,tag,lit,seq,rep,alt,opt,mem,get,term);
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
      case Get(e0,e1)       : get(sub(e0),sub(e1));
    }
  }*/
  public function toString(){
    return toString_with(Std.string);
  }
  public function toString_with(fn:T->String){
    var f   = (_:Lang<T>) -> _.toString_with(fn);
    var fI  = (_:Expr<T>) -> _.toString_with(fn);
    return switch this {
      case One              : '.';
      case Sip(e)           : 'Sip(${f(e)})';
      case App(name, args)  : 
        var arg = 
          __.option(args)
            .map(fI)
            .map(_ -> ' ($_)')
            .defv('');

      __.option(args).is_defined() ? 'App($name,$arg)' : 'App($name)';
      case Tag(name, val)   : 'Tag($name ${f(val)})';
      case Lit(e)           : 
        var representation = fI(e);
        'Lit(${representation})';
      case Seq(l, r)        : '${f(l)} ${f(r)}';
      case Rep(e)           : 'Rep(${f(e)})';
      case Alt(l, r)        : 'Alt(${f(l)} ${f(r)})';
      case Opt(e)           : 'Opt(${f(e)})';
      case Mem(e)           : 'Mem(${f(e)})';
      case Get(l, r)        : 'Get(${f(l)} :: ${f(r)})';
      //case Def(name,lang)   : 'Def($name,$lang)';
    }
  }
}