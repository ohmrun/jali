package stx.parse.jali.term;

import stx.parse.pack.parser.term.Identifier;

class Id extends stx.parse.pack.parser.term.Base<String,Lang<String>,Parser<String,Lang<String>>>{

  override function do_parse(ipt:Input<String>):ParseResult<String,Lang<String>>{
    var args = ipt.memo.symbols.get(this);
    return switch(args){
      case Label(code) : 
        new Identifier(code).asParser().then(Lit.fn().compose(Label)).parse(ipt);
      default : 
        ipt.fail('malformed input $args');
    }
  }
}