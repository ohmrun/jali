package eu.ohmrun.jali;

class Rule<T> extends haxe.ds.StringMap<Lang<T>>{
  public var name : String;
  public function new(name){
    super();
    this.name = name;
  }
  public function toArray():Array<Couple<String,Lang<T>>>{
    var out = [];
    for (key => val in this){
      out.push(__.couple(key,val));
    }
    return out;
  }
  public function show(){
    return "\n" + toArray().map(
      __.decouple(
        (l:String,r:Lang<T>) -> '$l :=    ${r.toString()}'
    )
    ).join("\n");
  }
}