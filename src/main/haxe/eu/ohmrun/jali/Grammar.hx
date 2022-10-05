package eu.ohmrun.jali;

import eu.ohmrun.Fletcher.FletcherApi;

import stx.parse.jali.term.Id;
import stx.parse.jali.term.Stash;
import stx.parse.jali.term.Memo;
import stx.parse.jali.term.Tag;
import stx.parse.jali.term.Get;

@:forward abstract Grammar<T>(GrammarCls<T>) from GrammarCls<T> to GrammarCls<T>{
  public function new(name:String) this = new GrammarCls(name,null,null);

  public function fromPExprs(map:StdMap<String,Lang<T>>){
    for( key => val in map){
      this.set(key,val.toParser(self));
    }
    return this;
  }

  public function prj():GrammarCls<T> return this;
  
  private var self(get,never):Grammar<T>;
  private function get_self():Grammar<T> return this;

}
class GrammarLift{
  //static public function id()
}