package stx.parse.jali.term;

import jali.pack.Lang in LangA;

class Lang<T> extends com.mindrocks.text.parsers.Base<T,LangA<T>,Parser<T,LangA<T>>>{
  var grammar : Grammar<T>;
  public function new(grammar,?id){
    super(id);
    this.grammar = grammar;
  }
  override function do_parse(ipt:Input<T>):ParseResult<T,LangA<T>>{
    return grammar.of('main').parse(ipt);
  }
}