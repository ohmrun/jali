package stx.parse;

import stx.parse.term.Literal;

class Jali extends Clazz{
  static var whitespace = Parse.whitespace;
  static function spaced<I,T>(p : Parser<String,T>) 
    return whitespace.many()._and(p).tagged(p.tag.def(p.name));

  static var l_brckt          = spaced("[".id()).tagged('l_brckt');
  static var r_brckt          = spaced("]".id()).tagged('r_brckt');

  static var literal          = new Literal().asParser().tagged('literal');

  static var alphanum         = Parse.alphanum;
  static var alpha            = Parse.alpha;
  static var underscore       = "_".id();
  static var ident_punc       = "._".split("").map(_-> _.id()).ors();
  //static var hook             = spaced("`".id());

  static var invalid_symbol_head_char   = 
    [
      whitespace,
      symbol_head_char
    ].ors();

  static var symbol_head_char = alpha.or(underscore);
    // head_guard
    // invalid_symbol_head_char
    //   .not()
    //   .lookahead()._and()
    
  static var symbol_body_char = alphanum.or(ident_punc);

  static var symbol_p         = 
    symbol_head_char
      .and(symbol_body_char.many())
      .then((tp:Couple<String,Array<String>>) -> [tp.fst()].concat(tp.snd()))
      .token()
      .tagged("symbol_p");

  static var token            = spaced(literal.or(symbol_p)).tagged("token");

  static function bracketed<O>(prs:Parser<String,O>):Parser<String,O>{
    return l_brckt._and(prs).and_(r_brckt).tagged(prs.tag.def(prs.name));
  }
  static public function term():Parser<String,Term<String>>{
    var deferred = term.defer().tagged('term');
    return token.many().and(bracketed(deferred).many()).then(
      __.decouple(
        (l:Array<String>,r) -> switch([l,r,l.length]){
          case [_,term,0]     : TOf(Rest,term);
          case [data,term,1]  : TOf(Code(data.head().fudge()),term);
          case [data,term,_]  : TOf(Data(data),term);
        }
      )
    );
  }
  public function main():Parser<String,Term<String>>{
    return term();
  }
  public function parse(ipt:Input<String>):ParseResult<String,Term<String>>{
    return main().parse(ipt);
  }
}