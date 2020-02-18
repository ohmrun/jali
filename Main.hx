using stx.core.Lift;

import jali.test.*;

class Main {
  static public function main(){
    __.test([
      new TermTest(),
      new LangTest(),
      new GeneratorTest()
    ]);
  }
}