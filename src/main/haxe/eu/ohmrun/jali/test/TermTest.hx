package jali.test;

import haxe.Serializer;
import haxe.Unserializer;


@:access(stx)class TermTest extends TestCase{
  public function test_declare(){
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
    //var t0000 = TPExpr.fromArray(t000);
    //trace(t0000);

    var term2 : Term<String>= TOf(Code("and"),[term0,term1]);
    trace(__.show(term2.prj()));
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
  public function testParser(){
    var string  = __.resource("texpr").string();
    var output  = Term.parse(string);
    switch(output){
      case Success(x,xs) : 
        trace(x);
      default :
        trace(output);
    }
  }
  public function XtestMod(){
    var string  = __.resource("texpr2").string();
    var output  = Term.parse(string);
    switch(output){
      case Success(x,xs) : 
        //x = Term.codeify(Term.optimise(x));
        trace(__.show(x.prj()));
        Terms._.mod(
          (t) -> {
            return t;
          },
          x
        );
      default :
        trace(output);
    }
  }
  public function XtestFails(){
    var string = __.resource("texpr_fails").string();
    var output = Term.parse(string);
    trace (output);
  }
}