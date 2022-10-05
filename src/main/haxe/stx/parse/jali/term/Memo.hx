package stx.parse.jali.term;
class Memo<T> extends stx.parse.parser.term.Delegate<T,Lang<T>>{
  override public function new(delegation:Parser<T,Lang<T>>,?id){
    super(delegation.memo(),id);
  } 
  override public function apply(ipt:Input<T>):ParseResult<T,Lang<T>>{
    var out = super.apply(ipt);
    return out;
  }
}