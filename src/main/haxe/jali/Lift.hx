package jali;

class Lift{
  static public function t<T>(_:Wildcard):Constructor<T>{
    return TOf;
  }
  static public function make<T>(_:jali.head.data.Constructor<T>):Constructor<T>{
    return t(__);
  }

  static public function apps<T>(arr:Array<String>):Array<Lang<T>>{
    return arr.map(App.bind(_,null));
  }
  static public function lits<T>(arr:Array<Term<T>>):Array<Lang<T>>{
    return arr.map(Lit);
  }
  static public function alts<T>(arr:Array<Lang<T>>):Lang<T>{
    return arr.rfold1(Alt.fn().flip().prj()).force();
  }
  static public function seqs<T>(arr:Array<Lang<T>>):Lang<T>{
    return arr.rfold1(Seq.fn().flip().prj()).force();
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
