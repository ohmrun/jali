package stx.parse.jali.term;

import jali.pack.Term in TermA;

class Term{
  public function new(){}
  static function spaced<I,T>(p : Parser<String,T>) 
    return Base.whitespace.many()._and(p).tagged(p.tag.def(p.name));

  static var l_brckt          = spaced("[".id()).tagged('l_brckt');
  static var r_brckt          = spaced("]".id()).tagged('r_brckt');

  static var literal          = new Literal().asParser().tagged('literal');
  static var alphanum         = Base.alphanum;
  static var alpha            = Base.alpha;
  static var ident_punc       = "._".split("").map(_-> _.id()).ors();
  //static var hook             = spaced("`".id());

  static var symbol_p         = alphanum.or(ident_punc).oneMany().token().tagged("symbol_p");
  static var token            = spaced(literal.or(symbol_p)).tagged("token");

  static function bracketed<O>(prs:Parser<String,O>):Parser<String,O>{
    return l_brckt._and(prs).and_(r_brckt).tagged(prs.tag.def(prs.name));
  }
  static public function term():Parser<String,TermA<String>>{
    var deferred = term.defer().tagged('term');
    return token.many().and(bracketed(deferred).many()).then(
      (tp) -> switch([tp,tp.fst().length]){
        case [tuple2(_,term),0]     : TOf(Rest,term);
        case [tuple2(data,term),1]  : TOf(Code(data.head().release()),term);
        case [tuple2(data,term),_]  : TOf(Data(data),term);
      }
    );
  }
  public function main():Parser<String,TermA<String>>{
    return term();
  }
  public function parse(ipt:Input<String>):ParseResult<String,TermA<String>>{
    return main().parse(ipt);
  }
}