package stx.parse.jali.term;

class Stash<T> extends stx.parse.pack.parser.term.Delegate<T,Lang<T>>{
  var value : Expr<T>;
  public function new(delegation,value,?pos){
    //__.assert().exists(value);
    super(delegation,pos);
    this.value = value;
  }
  override public function doApplyII(input:Input<T>,cont:Terminal<ParseResult<T,Lang<T>>,Noise>):Work{
    //trace('put: ${delegation.tag} $value');
    input.memo.symbols.set(delegation,value);
    return delegation.applyII(input,cont);
  }
}