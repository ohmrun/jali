package stx.parse.jali.term;

class Delegate<T,U> extends com.mindrocks.text.parsers.Base<T,Lang<U>,Parser<T,U>>{
  public function new(delegate,?id){
    super(delegate,id);
  }
  override function do_parse(ipt:Input<T>){
    return this.delegation.then(
      (x) -> Lit(TOf.make().datum(x,__))
    ).parse(ipt);
  }
}
//Tagged Delegate