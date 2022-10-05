package stx.parse.jali.term;

class Stash<T> extends stx.parse.parser.term.Delegate<T,Lang<T>>{
  var value : PExpr<T>;
  public function new(delegation,value,?pos){
    //__.assert().exists(value);
    super(delegation,pos);
    this.value = value;
  }
  override public function apply(input:Input<T>):ParseResult<T,Lang<T>>{
    //trace('put: ${delegation.tag} $value');
    input.memo.symbols.set(delegation,value);
    return delegation.apply(input);
  }
}