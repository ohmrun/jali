package stx.parse.jali.term;

import stx.parse.pack.parser.term.Identifier;

class Id extends stx.parse.pack.parser.term.Base<String,Lang<String>,Parser<String,Lang<String>>>{

  override function doApplyII(ipt:Input<String>,cont:Terminal<ParseResult<String,Lang<String>>,Noise>):Work{
    var args = ipt.memo.symbols.get(this);
    return switch(args){
      case Value(code) : 
        new Identifier(code).asParser().then(Lit.fn().compose(Value)).then(Lang.lift).applyII(ipt,cont);
      default : 
        cont.value(ipt.fail('malformed input $args')).serve();
    }
  }
}