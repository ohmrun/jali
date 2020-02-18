package stx.parse.jali.term;
class Memo<T> extends com.mindrocks.text.parsers.Delegate<T,Lang<T>>{
  override public function new(delegation:Parser<T,Lang<T>>,?id){
    super(delegation.memo(),id);
  } 
  override function do_parse(ipt:Input<T>):ParseResult<T, Lang<T>> {
    var out = super.do_parse(ipt);
    return out;
  }
}