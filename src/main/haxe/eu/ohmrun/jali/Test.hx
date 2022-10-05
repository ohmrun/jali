package eu.ohmrun.jali;

import eu.ohmrun.jali.Base;
using stx.Log;
using stx.Ds;
using stx.Async;
using eu.ohmrun.Jali;

import jali.test.*;

class Test{
  static public macro function boot(){
    __.test().run(
      [
        new OtherTest()
      ].last().toArray()
    );
    return macro {};
  }
  static public function main(){
    __.test().run([
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
    //__.log()(thing);
    var value     = Pml.parse(thing).fudge();
    //$type(value);
    trace(value);
    __.log()(value);
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
    return switch(__.log().through()(lang)){
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
      case Tag("Num",Lit(PLabel(str))) : 
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
      case Tag("Num",Lit(PLabel(str))) : Std.parseFloat(str);
      case Tag("Bracket",inner)       : interp(inner);
      default                         : throw 'fail: $lang';
    }
  }
}
class OtherTest extends haxe.unit.TestCase{
  public function testPEmptyParse(){
    
  }
}
class PmlParser{
  var grammar : Grammar<String>;
  private function new(){

  }
  static public function compile(expr:PExpr<Atom>){
    trace(expr);
    var parser = new PmlParser();
        parser.produce(expr);
    return parser;
  }
  public function parse(input:ParseInput<String>){
    return this.grammar.asParser().provide(input).fudge();
  }
  public function produce(expr:PExpr<Atom>){
    var reader = [expr].reader();
    var result = Parser.SyncAnon(type,Some('type')).provide(reader).fudge();
    return result;
  }
  public function type(i:ParseInput<PExpr<Atom>>){
    return switch(i.head()){
      case Some(PGroup(Cons(PValue(AnSym(key)),xs))) : 
        this.grammar = new Base(key);
        var reader  = xs.reader();
        var result  = Parser.SyncAnon(items,Some('items')).provide(reader).fudge();
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
  public function items(ipt:ParseInput<PExpr<Atom>>){
    trace(ipt.head().prj());
    return switch(ipt.head()){
      case Some(PGroup(xs)) :  
        var reader = xs.reader();
        var result = Parser.SyncAnon(item,Some('item')).many().provide(reader).fudge();
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
          ///case [Lit(PEmpty),_] : memo;
          //case [_,Lit(PEmpty)] : next;
          default             : Seq(next,memo);
        }
      }
    ).defv(One); 
  }
  function enalt(arr:Array<Lang<String>>) { return arr.lfold1(Alt).defv(One); }
  function anon(fn,tag) return Parser.SyncAnon(fn,tag);

  public function item(ipt:ParseInput<PExpr<Atom>>):ParseResult<PExpr<Atom>,Couple<String,Lang<String>>>{
    trace(ipt);
    return switch(ipt.head()){
      case Some(PGroup(Cons(PValue(Str(key)),Cons(PGroup(xs),Nil)))) : 
        trace(key);
        trace(xs);
        var reader  = xs.reader();
        var fn      = (arr:Array<Lang<String>>) -> arr.lfold1(Seq).defv(One);
        var result  = (Parser.SyncAnon(node,'node')).many().then(fn).provide(reader).convert(
          (res:ParseResult<PExpr<Atom>,Lang<String>>) -> res.map(lang ->__.couple(key,lang))
        ).fudge();
        var output  = result.value().defv(__.couple(key,Lit(PExprDef.PEmpty)));
        ipt.tail().ok(output);
      case null : 
        ipt.fail('');
      default   : 
        trace(ipt.head());
        ipt.fail('');
    }
  }
  public function seq(ipt:ParseInput<PExpr<Atom>>):ParseResult<PExpr<Atom>,Lang<String>>{
    trace('seq: $ipt');
    return switch(ipt.head()){
      case Some(PGroup(xs))    : 
        var reader = xs.reader();
        var result = anon(node,'node').one_many().then(enseq).provide(reader).fudge();
        trace(ipt.tail());
            result.tack(ipt.tail(),ipt);
      default           : ipt.fail('seq');
    }
  }
  public function app(ipt:ParseInput<PExpr<Atom>>):ParseResult<PExpr<Atom>,Lang<String>>{
    return switch(ipt.head()){
      case Some(PValue(AnSym(x))) : ipt.tail().ok(App(x));
      default                         : ipt.fail('app');
    }
  }
  //TODO why is this broken? Parser.Anon is the Identity of all under Memo?
  public function rop(name:String,cons:Lang<String>->Lang<String>):Parser<PExpr<Atom>,Lang<String>>{
    return Parser.SyncAnon((ipt:ParseInput<PExpr<Atom>>) -> 
      switch(ipt.head()){
        case Some(PValue(AnSym(name)))  : node(ipt.tail()).map(cons);
        default                             : ipt.fail(name);
      } 
    ,Some('rop'));
  }
  public function arg(ipt:ParseInput<PExpr<Atom>>):ParseResult<PExpr<Atom>,Lang<String>>{
    trace('arg: ${ipt.head().prj()}');
    //var reader = xs.reader();
    //var result = anon(node).one_many().then(enseq).parse(reader);
    return switch(ipt.head()){
      case Some(PGroup(xs))  : seq(ipt);
      default               : node(ipt);
    }
  }
  public function tag(ipt:ParseInput<PExpr<Atom>>):ParseResult<PExpr<Atom>,Lang<String>>{
    trace('tag: ${ipt.head().prj()}');
    return switch(ipt.head()){
      case Some(PValue(AnSym('tag'))) : 
        var rest = ipt.tail();
        trace(rest.head().prj());
        switch(rest.head()){
          case Some(PGroup(Cons(PValue(Str(str)),xs)))  : 
            arg(xs.reader()).map(Tag.bind(str)).tack(rest.tail(),ipt);
          default                               : ipt.fail('tag');
        }
      default : ipt.fail('tag');
    }
  }
  public function node(ipt:ParseInput<PExpr<Atom>>):ParseResult<PExpr<Atom>,Lang<String>>{
    trace('node: ${ipt.head().prj()}');
    return 
      Parser.Eof().not()
        ._and(
                anon(sip,Some('sip'))
            .or(anon(mem,Some('mem')))
            .or(anon(opt,Some('opt')))
            .or(anon(alt,Some('alt')))
            .or(anon(tag,Some('tag')))
            .or(anon(rep,Some('rep')))

            .or(anon(app_lit,Some('app_lit')))
            .or(anon(app,Some('app')))
      ).provide(ipt).fudge();
  }
  // public function nil(ipt:Input<PExpr<Atom>>):ParseResult<PExpr<Atom>,Lang<String>>{
  //   return switch(ipt.head()){
  //     case null : ipt.ok(Lit(PEmpty));
  //     default   : ipt.fail("nil");
  //   }
  // }
  public function sip(ipt:ParseInput<PExpr<Atom>>){
    trace('sip: ${ipt.head()}');
    return switch(ipt.head()){
      case Some(PValue(AnSym("sip"))) : arg(ipt.tail()).map(Sip);
      default                             : ipt.fail('sip');
    }
  }
  public function opt(ipt:ParseInput<PExpr<Atom>>){
    trace('opt: ${ipt.head().prj()}');
    return switch(ipt.head()){
      case Some(PValue(AnSym("opt"))) : arg(ipt.tail()).map(Opt);
      default                             : ipt.fail("opt");
    }
  }
  public function mem(ipt:ParseInput<PExpr<Atom>>){
    trace('mem: ${ipt.head().prj()}');
    return switch(ipt.head()){
      case Some(PValue(AnSym("mem")))      : arg(ipt.tail()).map(Mem);
      default                             : ipt.fail("mem");
    }
  }
  public function alt(ipt:ParseInput<PExpr<Atom>>){
    trace('alt: ${ipt.head().prj()}');
    return switch(ipt.head()){
      case Some(PValue(AnSym("alt"))) : 
        var result = anon(node,Some('node')).one_many();
        switch(ipt.tail().head()){
          case Some(PGroup(xs)) : 
            anon(node,Some('node'))
            .one_many()
            .then(enalt)
            .provide(xs.reader())
            .fudge()
            .tack(ipt.drop(2),ipt);
          default : ipt.fail("alt");
        }
      default : ipt.fail("alt");
    }
  }
  public function rep(ipt:ParseInput<PExpr<Atom>>){
    return switch(ipt.head()){
      case Some(PValue(AnSym("rep"))) : 
        seq(ipt.tail()).map(Rep);
      default : ipt.fail('rep');
    }
  }
  public function app_lit(ipt:ParseInput<PExpr<Atom>>){
    trace('app_lit: ${ipt.head().prj()}');
    return switch(ipt.head()){
      case Some(PValue(AnSym(key))) :
        switch(__.option(ipt.tail()).map( t -> t.head()).flat_map( v -> __.option(v) ) ){
          case Some(Some(PValue(Str(val))))  : ipt.drop(2).ok(App(key,PValue(val)));
          default                           : ipt.fail('app_lit: $key');
        }
      default : ipt.fail("app_lit");
    }
  }
}