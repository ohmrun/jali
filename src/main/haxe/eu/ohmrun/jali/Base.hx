package eu.ohmrun.jali;

import stx.parse.jali.term.Regex;
import stx.parse.jali.term.Stash;
import stx.parse.jali.term.Id;

class Base extends GrammarCls<String>{
  public function new(name:String,?rest){
    super(name,rest);
    this.set('id',    new Id().asParser());
    this.set('regex', new Regex().asParser());
  }
  
}
class BaseLift{
  /*
  static public function id():Parser<T,Lang<Atom>>{
    var parser = Parser.Anon((ipt:Input<Lang<Atom>>) -> {
      var stashed = ipt.memo.symbols.get(parser);
      return switch(stashed){
        case Group(Cons(Str(item))) : 
      }
    });
    return parser;
  }*/
}