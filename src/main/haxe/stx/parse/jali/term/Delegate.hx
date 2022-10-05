package stx.parse.jali.term;

class Delegate<T,U> extends stx.parse.parser.term.Base<T,Lang<U>,Parser<T,U>>{
  public function new(delegate,?id){
    super(delegate,id);
  }
  public function apply(ipt:Input<T>){
    return this.delegation.then( 
      (x) -> (Lit(PValue(x)):Lang<U>)
    ).apply(ipt);
  }
}
//Tagged Delegate