package jali.pack;

typedef Jsonic<T> = {
  //var type : JsonTerm;

  @:optional var code : String;
  @:optional var data : Array<T>;
  @:optional var rest : Array<Jsonic<T>>;
}