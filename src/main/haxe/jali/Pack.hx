package jali;

typedef Grammar<T>        = jali.pack.Grammar<T>;

typedef Rule<T>           = jali.pack.Rule<T>;

typedef LangSum<T>        = jali.pack.Lang.LangSum<T>;
typedef Lang<T>           = jali.pack.Lang<T>;

class LiftJali{

  static public function apps<T>(arr:Array<String>):Array<Lang<T>>{
    return arr.map(App.bind(_,null));
  }
  static public function lits<T>(arr:Array<Expr<T>>):Array<Lang<T>>{
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
  static public function app1<T>(key:String,exp:Expr<T>):Lang<T>{
    return App(key,exp);
  }
  static public function lit<T>(key:Expr<T>):Lang<T>{
    return Lit(key);
  }
}
