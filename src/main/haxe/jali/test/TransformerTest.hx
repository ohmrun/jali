package jali.test;

import jali.macro.Transformer;

class TransformerTest extends haxe.unit.TestCase{
  var data = __.resource("transformed").string();

  public function test(){
    var vals = Term.parse(data).value().fudge();
    var transformer = new Transformer(vals);
        transformer.deploy();
  }
}

class BaseClass{

}