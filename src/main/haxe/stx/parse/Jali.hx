
package stx.parse;

import stx.parse.term.Literal;

class Jali extends Clazz{
  static var whitespace = Parse.whitespace;
  static function spaced<I,T>(p : Parser<String,T>) 
    return whitespace.many()._and(p);

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
  static var symbol_body_char = alphanum.or(ident_punc);

  static var symbol_p         = 
    symbol_head_char
      .and(symbol_body_char.many())
      .then((tp:Couple<String,Array<String>>) -> [tp.fst()].concat(tp.snd()))
      .token()
      .tagged("symbol_p");

  static var token            = spaced(literal.or(symbol_p)).tagged("token");

  static function bracketed<O>(prs:Parser<String,O>):Parser<String,O>{
    return l_brckt._and(prs).and_(r_brckt);
  }
  static public function term():Parser<String,Term<String>>{
    var deferred  = term.defer().memo();

    var tail        = bracketed(deferred).then(Right).or(token.then(Left)).many().and_then(
      arr -> arr.all(
        (either) -> either.fold(
          (_) -> false,
          (_) -> true
        )
      ).if_else(
        () -> Parser.Succeed(arr.map_filter(
          (either) -> either.fold(
            (_)     -> None,
            (term)  -> Some(term)
          ))
        ),
        () -> Parser.Failed("trailing bare tokens",true)
      )
    );
    var kv        = token.and_(
      spaced(":".id())
    ).and(
      bracketed(deferred).or(token.then(TOf.make().code_only))
    ).then(
      (tp) -> TOf(Code(tp.fst()),TOf.make().body(tp.snd()))
    );
    return kv.one_many().then(TOf.make().rest).or(token.many().and(tail).then(
      __.decouple(
        (l:Array<String>,r:Array<Term<String>>) -> switch([l,r,l.length]){
          case [_,term,0]           : TOf(Rest,term);
          case [data,term,1]        : TOf(Code(data.head().fudge()),term);
          case [data,term,_]        : TOf(Data(data),term);
        }
      )
    ));
  }
  public function main():Parser<String,Term<String>>{
    return term().and_(Parse.eof());
  }
  public function parse(ipt:Input<String>):ParseResult<String,Term<String>>{
    return main().parse(ipt);
  }
}