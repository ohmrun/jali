package jali.test;

import haxe.Serializer;
import haxe.Unserializer;


@:access(stx)class TermTest extends haxe.unit.TestCase{
  public function Xtest_declare(){
    // likes (john , mary)
    trace("\n");
    var term0 = TOf(Code("likes"),[TOf(Data(["john","mary"]),[])]);
    trace(term0);
    // [likes, john, mary]
    var term1  = TOf(Data(["likes","john","mary"]),[]);
    trace(term1);

    var t0  = Serializer.run(term0);
    trace(t0);
    var t00 = Unserializer.run(t0);
    trace(t00);
    //var t000 = term0.toArray();
    //trace(t000);
    //var t0000 = TExpr.fromArray(t000);
    //trace(t0000);

    var term2 = TOf(Code("and"),[term0,term1]);
    trace(term2);
    /*

    */

    var map = [
      "a" => 1,
      "b" => 2
    ];
    var term3 = Term.fromMap(map);
    trace(term3);
    var term4 = __.t().code("tom").likes(__.t().code("mary"));
    trace(term4);
  }
  public function XtestParser(){
    var string  = __.resource("texpr").string();
    var output  = Term.parse(string);
    switch(output){
      case Success(x,xs) : 
        trace(x);
      default :
        trace(output);
    }
  }
  public function testMod(){
    var string  = __.resource("texpr2").string();
    var output  = Term.parse(string);
    switch(output){
      case Success(x,xs) : 
        x = Term.codeify(Term.optimise(x));
        trace(x);
        Term.mod(
          (t) -> {
            return t;
          },
          x
        );
      default :
        trace(output);
    }
  }
}