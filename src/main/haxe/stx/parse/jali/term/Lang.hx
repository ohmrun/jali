package stx.parse.jali.term;

import eu.ohmrun.jali.Lang in LangA;

class Lang<T> extends stx.parse.parser.term.Base<T,LangA<T>,Parser<T,LangA<T>>>{
  var grammar : Grammar<T>;
  public function new(grammar,?id){
    super(id);
    this.grammar = grammar;
  }
  function defer(ipt:Input<T>,cont:Terminal<ParseResult<T,LangA<T>>,Noise>):Work{
    return cont.receive(grammar.of('main').toFletcher().forward(ipt));
  }
}