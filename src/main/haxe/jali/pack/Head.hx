package jali.pack;

enum HeadSum<T>{
  Rest;
  Data(data:Array<T>);
  Code(code:String);
}

abstract Head<T>(HeadSum<T>) from HeadSum<T> to HeadSum<T>{
  public function new(self) this = self;
  static public function lift<T>(self:HeadSum<T>):Head<T> return new Head(self);
  

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
    ).flat_map(x->x);
  }
  public function data():Option<Array<T>>{
    return either(
      (_)       -> None,
      (data)    -> Some(data)
    ).flat_map(x->x);
  }
  public function is_term(){
    return this == Rest;
  }
  public function prj():HeadSum<T> return this;
  private var self(get,never):Head<T>;
  private function get_self():Head<T> return lift(this);
}