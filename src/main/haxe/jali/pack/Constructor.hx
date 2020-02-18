package jali.pack;

import jali.head.data.Tail in TailT;
import jali.head.data.Constructor in ConstructorT;

@:callable @:forward abstract Constructor<T>(ConstructorT<T>) from ConstructorT<T> to ConstructorT<T>{
  public function new(self) this = self;
  static public function lift<T>(self:ConstructorT<T>):Constructor<T> return new Constructor(self);
  
  public function last():Tail<T>{
    return Tail.unit();
  }
  public function tail(tail:TailT<T>):Tail<T>{
    return Tail.lift(tail);
  }
  public function body(body:Term<T>):Tail<T>{
    return tail([body]);
  }
  public function code(code:String):Term<T>{
    return this(Code(code),last());
  }
  public function call(code:String,rest:Tail<T>):Term<T>{
    return this(Code(code),rest);
  }
  public function call_data(code:String,rest:Array<T>):Term<T>{
    return this(Code(code),[data(rest,__)]);
  }
  public function datum(val:T,rest:Tail<T>):Term<T>{
    return this(Data([val]),rest);
  }
  public function data(val:Array<T>,rest:Tail<T>):Term<T>{
    return this(Data(val),rest);
  }
  public function rest(rest:Tail<T>):Term<T>{
    return this(Rest,rest);
  }

  public function prj():ConstructorT<T> return this;
  private var self(get,never):Constructor<T>;
  private function get_self():Constructor<T> return lift(this);

  
}