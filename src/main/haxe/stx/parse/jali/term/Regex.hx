package stx.parse.jali.term;

import stx.parse.pack.parser.term.Regex in RegexO;

class Regex extends stx.parse.pack.parser.term.Base<String,Lang<String>,Parser<String,Lang<String>>>{
  override public function do_parse(input:Input<String>):ParseResult<String,Lang<String>>{
    var args = input.memo.symbols.get(this);
    return switch(input.memo.symbols.get(this)){
      case TOf(Code(code),_)  : 
        new RegexO(code).asParser().then( _ -> Lit(TOf.make().code_only(_))).parse(input);
      default                 : 
        input.fail('malformed arguments $args',true);
    }
  }
}