package stx.parse.jali.term;

import stx.parse.parser.term.Identifier;

class Id extends stx.parse.parser.term.Base<String,Lang<String>,Parser<String,Lang<String>>>{

  function defer(ipt:Input<String>,cont:Terminal<ParseResult<String,Lang<String>>,Noise>):Work{
    var args = ipt.memo.symbols.get(this);
    return cont.receive(
      switch(args){
        case Value(code) : 
          new Identifier(code).asParser().then(Lit.fn().compose(Value)).then(Lang.lift).toFletcher().forward(ipt);
        default : 
          cont.value(ipt.fail('malformed input $args'));
      }
    );
  }
}