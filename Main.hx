using stx.Pico;
using stx.Nano;


using stx.Parse;

using eu.ohmrun.Jali;

import eu.ohmrun.jali.Test;

class Main {
  static macro function boot(){
    return Test.boot();
  }
  static public function main(){
    var f = __.log().global;
        f.includes.push("eu/ohmrun/jali");
        f.includes.push("eu/ohmrun/pml");
    Test.main();
  }
}
