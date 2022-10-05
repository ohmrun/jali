package stx.parse.jali.term;

import eu.ohmrun.jali.Lang in LangA;

class Lang<T> extends stx.parse.parser.term.Base<T,LangA<T>,Parser<T,LangA<T>>>{
  var grammar : Grammar<T>;
  public function new(grammar,?id){
    super(id);
    this.grammar = grammar;
  }
  public function apply(ipt:Input<T>):ParseResult<T,LangA<T>>{
    return grammar.of('main').apply(ipt);
  }
}