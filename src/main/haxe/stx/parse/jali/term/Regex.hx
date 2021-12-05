package stx.parse.jali.term;

import stx.parse.parser.term.Regex in RegexO;

class Regex extends stx.parse.parser.term.Base<String,Lang<String>,Parser<String,Lang<String>>>{
  public function defer(input:Input<String>,cont:Terminal<ParseResult<String,Lang<String>>,Noise>):Work{
    var args = input.memo.symbols.get(this);
    return cont.receive(
      switch(input.memo.symbols.get(this)){
        case Value(code) : 
          trace('"$code"');
          new RegexO('^$code')//TODO: should this be in the base class?
              .asParser()
              .then(Lit.fn().compose(Label))
              .then(Lang.lift)
              .toFletcher()
              .forward(input);
        default                 : 
          //trace(this);
          cont.value(input.fail('malformed arguments $args',true));
      }
    ); 
  }
}