package jali.pack;


typedef TailDef<T> = StdArray<Term<T>>;

@:forward abstract Tail<T>(TailDef<T>) from TailDef<T> to TailDef<T>{
  static public var ZERO = unit();
  @:arrayAccess
  public function get(int:Int):Term<T>{
    return this[int];
  }
  public function new(?self:TailDef<T>) this = __.option(self).defv([]);
  static public function lift<T>(self:TailDef<T>):Tail<T> return new Tail(self);
  static public function unit<T>():Tail<T> return lift([]);
  static public function once<T>(v:Term<T>):Tail<T> return lift([v]);

  @:from static public function fromWildcard<T>(wildcard:Wildcard):Tail<T>{
    return unit();
  }
  /*
  @:from static public function fromCard<T>(card:Card<Term<T>>):Tail<T>{
    return card.map(once).def(unit);
  }*/
  @:from static public function fromArrayT<T>(arr:Array<TermSum<T>>):Tail<T>{
    return lift(arr.prj());
  }
  public function body():Option<Term<T>>{
    return this.length == 1 ? this.head() : None;
  }
  public function data_body():Option<Couple<Array<T>,Tail<T>>>{
    return body().flat_map(
      term -> term.data()
    );
  }
  public function prj():TailDef<T> return this;
  private var self(get,never):Tail<T>;
  private function get_self():Tail<T> return lift(this);

  @:to public function toStdArray():StdArray<Term<T>>{
    return this;
  }
  public function is_defined(){
    return this.is_defined();
  }
  public function head(){
    return this.head();
  }
  public function tail():Tail<T>{
    return this.tail();
  }
  public function snoc(t:Term<T>):Tail<T>{
    return this.snoc(t);
  }
  public function toTerm(){
    return TOf(Rest,this);
  }
}