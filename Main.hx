using stx.Pico;
using stx.Nano;

import jali.test.*;

class Main {
  static macro function boot(){
    __.test(
      [new TransformerTest()]
    );
    return macro {};
  }
  static public function main(){
    // __.test([
    //   new LangTest(),
    //   new GeneratorTest(),
    //   new TermTest()
    // ]);
  }
}