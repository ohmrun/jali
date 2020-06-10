package stx.parse.jali.term;

class Delegate<T,U> extends stx.parse.pack.parser.term.Base<T,Lang<U>,Parser<T,U>>{
  public function new(delegate,?id){
    super(delegate,id);
  }
  override function do_parse(ipt:Input<T>){
    return this.delegation.then(
      (x) -> Lit(Value(x))
    ).parse(ipt);
  }
}
//Tagged Delegate