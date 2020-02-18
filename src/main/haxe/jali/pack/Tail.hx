package jali.pack;

import jali.head.data.Tail in TailT;

@:forward abstract Tail<T>(TailT<T>) from TailT<T> to TailT<T>{
  static public var ZERO = unit();
  @:arrayAccess
  public function get(int:Int):Term<T>{
    return this[int];
  }
  public function new(?self:TailT<T>) this = __.option(self).defv([]);
  static public function lift<T>(self:TailT<T>):Tail<T> return new Tail(self);
  static public function unit<T>():Tail<T> return lift([]);
  static public function once<T>(v:Term<T>):Tail<T> return lift([v]);

  @:from static public function fromWildcard<T>(wildcard:Wildcard):Tail<T>{
    return unit();
  }
  @:from static public function fromCard<T>(card:Stx<Term<T>>):Tail<T>{
    return card.map(once).def(unit);
  }
  @:from static public function fromArrayT<T>(arr:Array<jali.head.data.Term<T>>):Tail<T>{
    return lift(arr.prj());
  }
  public function body():Option<Term<T>>{
    return this.length == 1 ? this.ds().head() : None;
  }
  public function data_body():Option<Tuple2<Array<T>,Tail<T>>>{
    return body().fmap(
      term -> term.data()
    );
  }
  public function prj():TailT<T> return this;
  private var self(get,never):Tail<T>;
  private function get_self():Tail<T> return lift(this);

  @:to public function toStdArray():StdArray<Term<T>>{
    return this;
  }
}