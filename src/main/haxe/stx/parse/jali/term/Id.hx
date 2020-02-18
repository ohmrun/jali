package stx.parse.jali.term;

class Id extends com.mindrocks.text.parsers.Base<String,Lang<String>,Parser<String,Lang<String>>>{

  override function do_parse(ipt:Input<String>):ParseResult<String,Lang<String>>{
    var args = ipt.memo.symbols.get(this);
    return switch(args){
      case TOf(Code(code),_) : 
        new com.mindrocks.text.parsers.Identifier(code).asParser().then(
          TOf.make().code.fn().then(Lit)
        ).parse(ipt);
      default : 
        'malformed input $args'.no(ipt);
    }
  }
}