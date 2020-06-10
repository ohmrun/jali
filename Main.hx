using stx.Pico;
using stx.Nano;
using stx.Std;
using stx.parse.Pack;

using jali.Pack;

import jali.test.*;

class Main {
  static macro function boot(){
    __.test(
      [
        new OtherTest()
      ].last().toArray()
    );
    return macro {};
  }
  static public function main(){
     __.test([
    //   new LangTest(),
    //   new GeneratorTest(),
          new OtherTest(),
          new BareNakedTest()
    ].last().toArray());
  }
}
class BareNakedTest extends haxe.unit.TestCase{
  public function test_1(){
    var string = __.resource("bare_naked").string();
    var result = new stx.parse.Jali().parse(string.reader());
    trace(result);
 
    var err = result.error().fudge().with;
    for (e in err){
      trace(e);
    }
  }
}
class OtherTest extends haxe.unit.TestCase{
  public function testEmptyParse(){
    var string = "";
    var result = Term.parse(string);
  }
}