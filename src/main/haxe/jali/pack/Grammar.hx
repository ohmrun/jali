package jali.pack;

import jali.type.Grammar in GrammarT;

@:forward abstract Grammar<T>(GrammarT<T>) from GrammarT<T> to GrammarT<T>{
  public function new(name:String) this = new GrammarT(name);

  public function fromExprs(map:StdMap<String,Lang<T>>){
    for( key => val in map){
      this.set(key,val.toParser(self));
    }
    return this;
  }

  public function prj():GrammarT<T> return this;
  
  private var self(get,never):Grammar<T>;
  private function get_self():Grammar<T> return this;
}