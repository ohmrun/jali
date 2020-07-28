package stx.parse.jali.term;

import eu.ohmrun.jali.Lang in LangA;

class Lang<T> extends stx.parse.pack.parser.term.Base<T,LangA<T>,Parser<T,LangA<T>>>{
  var grammar : Grammar<T>;
  public function new(grammar,?id){
    super(id);
    this.grammar = grammar;
  }
  override function doApplyII(ipt:Input<T>,cont:Terminal<ParseResult<T,LangA<T>>,Noise>):Work{
    return grammar.of('main').applyII(ipt,cont);
  }
}