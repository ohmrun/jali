package stx.parse.jali.term;

class Tag<T,U> extends stx.parse.pack.parser.term.Base<T,Lang<U>,Parser<T,Lang<U>>>{
  var label : String;
  public function new(label,delegation:Parser<T,Lang<U>>,?id){
    super(delegation,id);
    this.label = label;
  }
  override function doApplyII(ipt:Input<T>,cont:Terminal<ParseResult<T,Lang<U>>,Noise>):Work{
    return this.delegation.then(
      (v) -> (Tag(label,v):Lang<U>)
    ).applyII(ipt,cont);
  }
}