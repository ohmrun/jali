package jali;

typedef Grammar<T>        = jali.pack.Grammar<T>;

typedef Rule<T>           = jali.pack.Rule<T>;

typedef LangSum<T>        = jali.pack.Lang.LangSum<T>;
typedef Lang<T>           = jali.pack.Lang<T>;

typedef TermSum<T>        = jali.pack.Term.TermSum<T>;
typedef Term<T>           = jali.pack.Term<T>;
typedef Jali<T>           = Term<T>;

typedef ConstructorDef<T> = jali.pack.Constructor.ConstructorDef<T>;
typedef Constructor<T>    = jali.pack.Constructor<T>;

typedef Head<T>           = jali.pack.Head<T>;
typedef TailDef<T>        = jali.pack.Tail.TailDef<T>;
typedef Tail<T>           = jali.pack.Tail<T>;

class LiftJali{
  static public function make<T>(_:ConstructorDef<T>):Constructor<T>{
    return TOf;
  }

  static public function apps<T>(arr:Array<String>):Array<Lang<T>>{
    return arr.map(App.bind(_,null));
  }
  static public function lits<T>(arr:Array<Term<T>>):Array<Lang<T>>{
    return arr.map(Lit);
  }
  static public function alts<T>(arr:Array<Lang<T>>):Lang<T>{
    return arr.rfold1(Alt.fn().swap()).fudge();
  }
  static public function seqs<T>(arr:Array<Lang<T>>):Lang<T>{
    return arr.rfold1(Seq.fn().swap()).fudge();
  }
  static public function app<T>(key:String):Lang<T>{
    return App(key);
  }
  static public function app1<T>(key:String,exp:Term<T>):Lang<T>{
    return App(key,exp);
  }
  static public function lit<T>(key:Term<T>):Lang<T>{
    return Lit(key);
  }
}
