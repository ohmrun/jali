package jali.head.data;

typedef Jsonic<T> = {
  var type : JsonTerm;

  @:optional var code : Null<String>;
  @:optional var data : Null<Array<T>>;
  var rest            : Array<Jsonic<T>>;
}