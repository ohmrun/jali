package stx.parse.jali.term;

import stx.parse.pack.parser.term.Regex in RegexO;

class Regex extends stx.parse.pack.parser.term.Base<String,Lang<String>,Parser<String,Lang<String>>>{
  override public function doApplyII(input:Input<String>,cont:Terminal<ParseResult<String,Lang<String>>,Noise>):Work{
    var args = input.memo.symbols.get(this);
    return switch(input.memo.symbols.get(this)){
      case Value(code) : 
        trace('"$code"');
        new RegexO('^$code')//TODO: should this be in the base class?
            .asParser()
            .then(Lit.fn().compose(Label))
            .then(Lang.lift)
            .applyII(input,cont);
      default                 : 
        //trace(this);
        cont.value(input.fail('malformed arguments $args',true)).serve();
    }
  }
}