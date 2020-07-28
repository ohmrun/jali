package stx.parse.jali.term;

class Recode extends stx.parse.pack.parser.term.Base<String,Lang<String>,Parser<String,String>>{
  public function new(delegate,?id){
    super(delegate,id);
  }
  override function doApplyII(ipt:Input<String>,cont:Terminal<ParseResult<String,Lang<String>>,Noise>){
    return this.delegation.then(
      (x) -> (Lit(Label(x)):Lang<String>)
    ).applyII(ipt,cont);
  }
}