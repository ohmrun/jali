package stx.parse.jali.term;

class Stash<T> extends stx.parse.pack.parser.term.Delegate<T,Lang<T>>{
  var value : Expr<T>;
  public function new(delegation,value,?pos){
    super(delegation,pos);
    this.value = value;
  }
  override public function do_parse(input:Input<T>):ParseResult<T,Lang<T>>{
    input.memo.symbols.set(delegation,value);
    return delegation.parse(input);
  }
}