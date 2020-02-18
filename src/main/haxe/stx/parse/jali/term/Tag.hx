package stx.parse.jali.term;

class Tag<T,U> extends com.mindrocks.text.parsers.Base<T,Lang<U>,Parser<T,Lang<U>>>{
  var identifier : String;
  public function new(identifier,delegation:Parser<T,Lang<U>>,?id){
    super(delegation,id);
    this.identifier = identifier;
  }
  override function do_parse(ipt:Input<T>){
    return this.delegation.then(
      (v) -> Tag(identifier,v)
    ).parse(ipt);
  }
}