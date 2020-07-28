package stx.parse.jali.term;

class Get<T> extends stx.parse.pack.parser.term.Delegate<T,Lang<T>>{
  private var result : Lang<T>;
  public function new(delegate,result:Lang<T>,?id){
    super(delegate,id);
    this.result = result;
  }
  override function doApplyII(ipt:Input<T>,cont:Terminal<ParseResult<T,Lang<T>>,Noise>){
    return this.delegation.then(
      (_) -> result
    ).applyII(ipt,cont);
  }
}