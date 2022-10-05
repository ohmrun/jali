package stx.parse.jali.term;

class Get<T> extends stx.parse.parser.term.Delegate<T,Lang<T>>{
  var stored : Lang<T>;
  public function new(delegate,stored:Lang<T>,?id){
    super(delegate,id);
    this.stored = stored;
  }
  override inline function apply(ipt:Input<T>){
    return this.delegation.then(
      (_) -> stored
    ).apply(ipt);
  }
}