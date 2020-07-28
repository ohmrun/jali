package jali.test;

class LangTest extends haxe.unit.TestCase{
  var lexer : Grammar<String> = new Grammar("SimpleParser").fromExprs(
    [
      'p_star_id'   => 'id'.app1(__.t().code("x")),
      'p_plus_id'   => 'id'.app1(__.t().code("+")),
      'p_int'       => 'regex'.app1(__.t().code("[0-9]+")).tag('Num'),
      'p_expr'      => ['p_mult','p_plus','p_int'].apps().alts().mem(),
      'p_mult'      => ['p_expr','p_star_id','p_expr'].apps().seqs().tag('Mult'),
      'p_plus'      => ['p_expr','p_plus_id','p_expr'].apps().seqs().tag('Plus'),
      'main'        => 'p_expr'.app()
    ]
  );
  public function new(){
    super();
    lexer.set('id'    , new Id().asParser());
    lexer.set('regex' , new Regex().asParser());
    lexer.set('p_int' , new Recode(stx.prs.pack.Base.digit.oneMany().token()).asParser());
    //lexer.set('eof'   , new Recode(stx.prs.pack.Base.digit.oneMany().token()).asParser());
  }
  public function testId(){
    var out = lexer.get('p_star_id').parse('x'.reader());
    assertTrue(out.isSuccess());
  }
  //TODO
  public function Xtest_mult(){
    var out = lexer.get('p_mult').parse('1x2'.reader());
    trace(out);
    assertTrue(out.isSuccess());
  }
  public function test_simple(){
    var out = lexer.get('main').parse('1x2'.reader());
    assertTrue(out.isSuccess());
  }
  public function test(){
    var t = "1+2+3x4x9x10";
    var out = lexer.parse(t.reader());
    trace(out);
    assertTrue(out.isSuccess());
  }
}
enum Expr{
  Mult(l:Expr,r:Expr);
  Plus(l:Expr,r:Expr);
  Num(v:Int);
}