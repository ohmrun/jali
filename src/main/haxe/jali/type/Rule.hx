package jali.type;

class Rule<T> extends haxe.ds.StringMap<Lang<T>>{
  public var name : String;
  public function new(name){
    super();
    this.name = name;
  }
  public function toArray():Array<Tuple2<String,Lang<T>>>{
    var out = [];
    for (key => val in this){
      out.push(tuple2(key,val));
    }
    return out;
  }
  override public function toString(){
    return "\n" + toArray().map(
      __.into2(
        (l:String,r:Lang<T>) -> '$l :=    ${r.toString()}'
      )
    ).join("\n");
  }
}