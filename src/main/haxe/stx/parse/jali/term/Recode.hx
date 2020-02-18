package stx.parse.jali.term;

class Recode extends com.mindrocks.text.parsers.Base<String,Lang<String>,Parser<String,String>>{
  public function new(delegate,?id){
    super(delegate,id);
  }
  override function do_parse(ipt:Input<String>){
    return this.delegation.then(
      (x) -> Lit(TOf.make().code(x))
    ).parse(ipt);
  }
}