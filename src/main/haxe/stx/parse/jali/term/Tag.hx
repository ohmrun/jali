package stx.parse.jali.term;

class Tag<T,U> extends stx.parse.parser.term.Then<T,Lang<U>,Lang<U>>{
  var label : String;
  public function new(label,delegation:Parser<T,Lang<U>>,?pos){
    super(delegation,pos);
    this.label = label;
  }
  function transform(lang:Lang<U>):Lang<U>{
    return (Tag(label,lang):Lang<U>);
  }
}