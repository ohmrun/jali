package stx.parse.jali.term;

class Tag<T,U> extends stx.parse.pack.parser.term.Base<T,Lang<U>,Parser<T,Lang<U>>>{
  var label : String;
  public function new(label,delegation:Parser<T,Lang<U>>,?id){
    super(delegation,id);
    this.label = label;
  }
  override function do_parse(ipt:Input<T>){
    return this.delegation.then(
      (v) -> Tag(label,v)
    ).parse(ipt);
  }
}