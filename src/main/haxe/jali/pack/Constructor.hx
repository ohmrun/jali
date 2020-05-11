package jali.pack;


typedef ConstructorDef<T> = Head<T> -> Tail<T> -> Term<T>;

@:callable @:forward abstract Constructor<T>(ConstructorDef<T>) from ConstructorDef<T> to ConstructorDef<T>{
  public function new(self) this = self;
  static public function lift<T>(self:ConstructorDef<T>):Constructor<T> return new Constructor(self);
  
  /**
    constructor
  **/
  public function unit():Term<T>{
    return rest(last());
  }
  /**
    constructor
  **/
  public function last():Tail<T>{
    return Tail.unit();
  }
  /**
    tail constructor
  **/
  public function tail(tail:TailDef<T>):Tail<T>{
    return Tail.lift(tail);
  }
  /**
    tail constructor with one entry
  **/
  public function body(body:Term<T>):Tail<T>{
    return tail([body]);
  }
  /**
    constructor
  **/
  public function code_only(code:String):Term<T>{
    return this(Code(code),last());
  }
  /**
    constructor
  **/
  public function code(code:String,rest:Tail<T>):Term<T>{
    return this(Code(code),rest);
  }
  /**
    constructor
  **/
  public function code_data(code:String,rest:Array<T>):Term<T>{
    return this(Code(code),[data(rest,__)]);
  }
    /**
    constructor
  **/
  public function datum(val:T,?rest:Tail<T>):Term<T>{
    return this(Data([val]),__.option(rest).def(last));
  }
    /**
    constructor
  **/
  public function data(val:Array<T>,rest:Tail<T>):Term<T>{
    return this(Data(val),rest);
  }  /**
  constructor
**/
  public function rest(rest:Tail<T>):Term<T>{
    return this(Rest,rest);
  }
  public function subtree(head:Term<T>,body:Term<T>):Term<T>{
    return rest(
      TOf.make().tail([head,TOf.make().body(body).toTerm()])
    );
  }
  public function prj():ConstructorDef<T> return this;
  private var self(get,never):Constructor<T>;
  private function get_self():Constructor<T> return lift(this);

  
}