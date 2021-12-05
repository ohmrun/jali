package stx.parse.jali.term;

class Get<T> extends stx.parse.parser.term.Delegate<T,Lang<T>>{
  var stored : Lang<T>;
  public function new(delegate,stored:Lang<T>,?id){
    super(delegate,id);
    this.stored = stored;
  }
  override inline function defer(ipt:Input<T>,cont:Terminal<ParseResult<T,Lang<T>>,Noise>){
    return this.delegation.then(
      (_) -> stored
    ).defer(ipt,cont);
  }
}