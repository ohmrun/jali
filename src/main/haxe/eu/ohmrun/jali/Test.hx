package eu.ohmrun.jali;

import eu.ohmrun.jali.Base;
using stx.Log;
using stx.Ds;
using stx.Async;

import jali.test.*;

class Test{
  static public macro function boot(){
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
    var thing     = __.resource('grammar').string();
    var value     = Pml.parse(thing).fudge();
    trace(value);
    //var parser    = PmlParser.compile(value.fudge().value().fudge());

    //var example   = __.resource('use_grammar').string();
    //trace(example);
    //var result    = parser.parse(example.reader());
    //trace(result.error());
    //var parsed    = result.value().fudge();
    //var value     = interp(parsed);
    //trace(value);
  }
  function interp1(lang:Lang<String>):Float{
    return switch(__.logger()(lang)){
      case Tag("Plus", Seq(l,r) ) : 
        var lhs = interp(l);
        var rhs = interp(r);
        trace('$lhs + $rhs');
        return lhs + rhs;
      case Tag("Mult", Seq(l,r) ) : 
        var lhs = interp(l);
        var rhs = interp(r);
        trace('$lhs * $rhs');
        return lhs * rhs;
      case Tag("Num",Lit(Label(str))) : 
        Std.parseFloat(str);
      case Tag("Bracket",inner) : 
        interp(inner);
      default : 
        trace(lang);
        throw lang;
        0.0;
    }
  }
  function interp(lang:Lang<String>):Float{ 
    return switch(lang){
      case Tag("Plus", Seq(l,r) )     : interp(l) + interp(r);
      case Tag("Mult", Seq(l,r) )     : interp(l) * interp(r);
      case Tag("Num",Lit(Label(str))) : Std.parseFloat(str);
      case Tag("Bracket",inner)       : interp(inner);
      default                         : throw 'fail: $lang';
    }
  }
}
class OtherTest extends haxe.unit.TestCase{
  public function testEmptyParse(){
    
  }
}
class PmlParser{
  var grammar : Grammar<String>;
  private function new(){

  }
  static public function compile(expr:Expr<Atom>){
    trace(expr);
    var parser = new PmlParser();
        parser.produce(expr);
    return parser;
  }
  public function parse(input:Input<String>){
    return this.grammar.asParser().forward(input).fudge();
  }
  public function produce(expr:Expr<Atom>){
    var reader = [expr].reader();
    var result = Parser.SyncAnon(type).forward(reader).fudge();
    return result;
  }
  public function type(i:Input<Expr<Atom>>){
    return switch(i.head()){
      case Some(Group(Cons(Value(AnSym(key)),xs))) : 
        this.grammar = new Base(key);
        var reader  = xs.reader();
        var result  = Parser.SyncAnon(items).forward(reader).fudge();
        result.map(
          (arr:Array<Couple<String,Lang<String>>>) -> {
            for(tp in arr){
              grammar.set(tp.fst(),grammar.lazy(tp.snd()));
            }
            return Noise;
          }
        );
      default : i.fail("type");
    }
  }
  public function items(ipt:Input<Expr<Atom>>){
    trace(ipt.head().prj());
    return switch(ipt.head()){
      case Some(Group(xs)) :  
        var reader = xs.reader();
        var result = Parser.SyncAnon(item).many().forward(reader).fudge();
        var show   = result.value().defv([]);
        for( tp in show ){
          var k = tp.fst();
          var v = tp.snd();
          __.log()('$k: $v');
        }
        result;
      default : ipt.fail("items");
    }
  }
  function enseq(arr:Array<Lang<String>>) { 
    return arr.lfold1(
      (next,memo) -> {
        //trace('$next $memo');
         return switch([next,memo]){
          ///case [Lit(Empty),_] : memo;
          //case [_,Lit(Empty)] : next;
          default             : Seq(next,memo);
        }
      }
    ).defv(One); 
  }
  function enalt(arr:Array<Lang<String>>) { return arr.lfold1(Alt).defv(One); }
  function anon(fn) return Parser.SyncAnon(fn);

  public function item(ipt:Input<Expr<Atom>>):ParseResult<Expr<Atom>,Couple<String,Lang<String>>>{
    trace(ipt);
    return switch(ipt.head()){
      case Some(Group(Cons(Value(Str(key)),Cons(Group(xs),Nil)))) : 
        trace(key);
        trace(xs);
        var reader  = xs.reader();
        var fn      = (arr:Array<Lang<String>>) -> arr.lfold1(Seq).defv(One);
        var result  = (Parser.SyncAnon(node)).many().then(fn).forward(reader).process(
          (res:ParseResult<Expr<Atom>,Lang<String>>) -> res.map(lang ->__.couple(key,lang))
        ).fudge();
        var output  = result.value().defv(__.couple(key,Lit(ExprDef.Empty)));
        ipt.tail().ok(output);
      case null : 
        ipt.fail('');
      default   : 
        trace(ipt.head());
        ipt.fail('');
    }
  }
  public function seq(ipt:Input<Expr<Atom>>):ParseResult<Expr<Atom>,Lang<String>>{
    trace('seq: $ipt');
    return switch(ipt.head()){
      case Some(Group(xs))    : 
        var reader = xs.reader();
        var result = anon(node).one_many().then(enseq).forward(reader).fudge();
        trace(ipt.tail());
            result.tack(ipt.tail(),ipt);
      default           : ipt.fail('seq');
    }
  }
  public function app(ipt:Input<Expr<Atom>>):ParseResult<Expr<Atom>,Lang<String>>{
    return switch(ipt.head()){
      case Some(Value(AnSym(x))) : ipt.tail().ok(App(x));
      default                         : ipt.fail('app');
    }
  }
  //TODO why is this broken? Parser.Anon is the Identity of all under Memo?
  public function rop(name:String,cons:Lang<String>->Lang<String>):Parser<Expr<Atom>,Lang<String>>{
    return Parser.SyncAnon((ipt:Input<Expr<Atom>>) -> 
      switch(ipt.head()){
        case Some(Value(AnSym(name)))  : node(ipt.tail()).map(cons);
        default                             : ipt.fail(name);
      } 
    );
  }
  public function arg(ipt:Input<Expr<Atom>>):ParseResult<Expr<Atom>,Lang<String>>{
    trace('arg: ${ipt.head().prj()}');
    //var reader = xs.reader();
    //var result = anon(node).one_many().then(enseq).parse(reader);
    return switch(ipt.head()){
      case Some(Group(xs))  : seq(ipt);
      default               : node(ipt);
    }
  }
  public function tag(ipt:Input<Expr<Atom>>):ParseResult<Expr<Atom>,Lang<String>>{
    trace('tag: ${ipt.head().prj()}');
    return switch(ipt.head()){
      case Some(Value(AnSym('tag'))) : 
        var rest = ipt.tail();
        trace(rest.head().prj());
        switch(rest.head()){
          case Some(Group(Cons(Value(Str(str)),xs)))  : 
            arg(xs.reader()).map(Tag.bind(str)).tack(rest.tail(),ipt);
          default                               : ipt.fail('tag');
        }
      default : ipt.fail('tag');
    }
  }
  public function node(ipt:Input<Expr<Atom>>):ParseResult<Expr<Atom>,Lang<String>>{
    trace('node: ${ipt.head().prj()}');
    return 
      Parse.eof().not()
        ._and(
                anon(sip)
            .or(anon(mem))
            .or(anon(opt))
            .or(anon(alt))
            .or(anon(tag))
            .or(anon(rep))

            .or(anon(app_lit))
            .or(anon(app))
      ).forward(ipt).fudge();
  }
  // public function nil(ipt:Input<Expr<Atom>>):ParseResult<Expr<Atom>,Lang<String>>{
  //   return switch(ipt.head()){
  //     case null : ipt.ok(Lit(Empty));
  //     default   : ipt.fail("nil");
  //   }
  // }
  public function sip(ipt:Input<Expr<Atom>>){
    trace('sip: ${ipt.head()}');
    return switch(ipt.head()){
      case Some(Value(AnSym("sip"))) : arg(ipt.tail()).map(Sip);
      default                             : ipt.fail('sip');
    }
  }
  public function opt(ipt:Input<Expr<Atom>>){
    trace('opt: ${ipt.head().prj()}');
    return switch(ipt.head()){
      case Some(Value(AnSym("opt"))) : arg(ipt.tail()).map(Opt);
      default                             : ipt.fail("opt");
    }
  }
  public function mem(ipt:Input<Expr<Atom>>){
    trace('mem: ${ipt.head().prj()}');
    return switch(ipt.head()){
      case Some(Value(AnSym("mem"))) : arg(ipt.tail()).map(Mem);
      default                             : ipt.fail("mem");
    }
  }
  public function alt(ipt:Input<Expr<Atom>>){
    trace('alt: ${ipt.head().prj()}');
    return switch(ipt.head()){
      case Some(Value(AnSym("alt"))) : 
        var result = anon(node).one_many();
        switch(ipt.tail().head()){
          case Some(Group(xs)) : 
            anon(node)
            .one_many()
            .then(enalt)
            .forward(xs.reader())
            .fudge()
            .tack(ipt.drop(2),ipt);
          default : ipt.fail("alt");
        }
      default : ipt.fail("alt");
    }
  }
  public function rep(ipt:Input<Expr<Atom>>){
    return switch(ipt.head()){
      case Some(Value(AnSym("rep"))) : 
        seq(ipt.tail()).map(Rep);
      default : ipt.fail('rep');
    }
  }
  public function app_lit(ipt:Input<Expr<Atom>>){
    trace('app_lit: ${ipt.head().prj()}');
    return switch(ipt.head()){
      case Some(Value(AnSym(key))) :
        switch(__.option(ipt.tail()).map( t -> t.head()).flat_map( v -> __.option(v) ) ){
          case Some(Some(Value(Str(val))))  : ipt.drop(2).ok(App(key,Value(val)));
          default                           : ipt.fail('app_lit: $key');
        }
      default : ipt.fail("app_lit");
    }
  }
}