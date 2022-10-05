package stx.parse.jali.term;

import stx.parse.parser.term.Identifier;

class Id extends stx.parse.parser.term.Base<String,Lang<String>,Parser<String,Lang<String>>>{

  public function apply(ipt:Input<String>):ParseResult<String,Lang<String>>{
    var args = ipt.memo.symbols.get(this);
    return switch(args){
      case PValue(code) : 
        new Identifier(code).asParser().then(Lit.fn().compose(PValue)).then(Lang.lift).apply(ipt);
      default : 
        ipt.no('malformed input $args');
    }
  }
}