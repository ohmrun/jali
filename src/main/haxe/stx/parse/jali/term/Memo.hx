package stx.parse.jali.term;
class Memo<T> extends stx.parse.parser.term.Delegate<T,Lang<T>>{
  override public function new(delegation:Parser<T,Lang<T>>,?id){
    super(delegation.memo(),id);
  } 
  override function defer(ipt:Input<T>,cont:Terminal<ParseResult<T,Lang<T>>,Noise>):Work{
    var out = super.defer(ipt,cont);
    return out;
  }
}