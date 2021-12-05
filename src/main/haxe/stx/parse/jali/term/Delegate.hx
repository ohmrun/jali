package stx.parse.jali.term;

class Delegate<T,U> extends stx.parse.parser.term.Base<T,Lang<U>,Parser<T,U>>{
  public function new(delegate,?id){
    super(delegate,id);
  }
  function defer(ipt:Input<T>,cont:Terminal<ParseResult<T,Lang<U>>,Noise>){
    return this.delegation.then( 
      (x) -> (Lit(Value(x)):Lang<U>)
    ).defer(ipt,cont);
  }
}
//Tagged Delegate