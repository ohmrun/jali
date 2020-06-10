package jali.test;

using stx.parse.Pack;
import jali.macro.Transformer;

class TransformerTest extends haxe.unit.TestCase{
  var data = __.resource("transformed").string();

  public function test(){
    var vals = new stx.parse.Jali().parse(data.reader()).value().fudge();
    var transformer = new Transformer(vals);
        transformer.deploy();
  }
}

class BaseClass{

}