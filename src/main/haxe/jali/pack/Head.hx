package jali.pack;

import jali.head.data.Head in HeadT;

abstract Head<T>(HeadT<T>) from HeadT<T> to HeadT<T>{
  public function new(self) this = self;
  static public function lift<T>(self:HeadT<T>):Head<T> return new Head(self);
  

  public function fold<Z>(code:String->Z,data:Array<T>->Z,unit:Void->Z):Z{
    return switch(this){
      case Rest        : unit();
      case Data(_data) : data(_data);
      case Code(_code) : code(_code);
    }
  }
  public function either<Z>(code:String->Z,data:Array<T>->Z):Option<Z>{
    return fold(
      (_code) -> Some(code(_code)),
      (_data) -> Some(data(_data)),
      () -> None
    );
  }
  @:to public function toOptionEither():Option<Either<String,Array<T>>>{
    return fold(
      (code)  -> Some(Left(code)),
      (data)  -> Some(Right(data)),
      ()      -> None
    );
  }
  public function cat(){
    return toOptionEither();
  }
  public function code():Option<String>{
    return either(
      (code) -> Some(code),
      (_)    -> None
    ).fmap(x->x);
  }
  public function data():Option<Array<T>>{
    return either(
      (_)       -> None,
      (data)    -> Some(data)
    ).fmap(x->x);
  }
  public function is_term(){
    return this == Rest;
  }
  public function prj():HeadT<T> return this;
  private var self(get,never):Head<T>;
  private function get_self():Head<T> return lift(this);
}