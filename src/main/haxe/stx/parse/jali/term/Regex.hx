package stx.parse.jali.term;
import com.mindrocks.text.parsers.Regex in RegexO;

class Regex extends com.mindrocks.text.parsers.Base<String,Lang<String>,Parser<String,Lang<String>>>{
  override public function do_parse(input:Input<String>):ParseResult<String,Lang<String>>{
    var args = input.memo.symbols.get(this);
    return switch(input.memo.symbols.get(this)){
      case TOf(Code(code),_)  : 
        new RegexO(code).asParser().then( _ -> Lit(TOf.make().code(_))).parse(input);
      default                 : 
        'malformed arguments $args'.no(input,true);
    }
  }
}