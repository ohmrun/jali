package stx.parse.jali.term;

import stx.parse.parser.term.Regex in RegexO;

class Regex extends stx.parse.parser.term.Base<String,Lang<String>,Parser<String,Lang<String>>>{
  public function apply(input:Input<String>):ParseResult<String,Lang<String>>{
    var args = input.memo.symbols.get(this);
    return switch(input.memo.symbols.get(this)){
      case PValue(code) : 
        trace('"$code"');
        new RegexO('^$code')//TODO: should this be in the base class?
            .asParser()
            .then(Lit.fn().compose(PLabel))
            .then(Lang.lift)
            .apply(input);
      default                 : 
        //trace(this);
        input.no('malformed arguments $args',true);
    }
  }
}