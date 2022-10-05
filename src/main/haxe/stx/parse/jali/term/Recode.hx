package stx.parse.jali.term;

class Recode extends stx.parse.parser.term.Then<String,String,Lang<String>>{
  public function new(delegate,?id){
    super(delegate,id);
  }
  inline function transform(string:String){
    return (Lit(PLabel(string)):Lang<String>);
  }
}