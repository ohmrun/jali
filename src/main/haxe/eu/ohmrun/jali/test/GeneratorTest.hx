package jali.test;

import jali.test.GeneratorTest.ExprAs.*;

import hscript.Async;
import hscript.Bytes;
import hscript.Checker;
import hscript.Expr;
import hscript.Interp;
import hscript.Macro;
import hscript.Parser;
import hscript.Printer;
import hscript.Tools;

import jali.test.Generator.*;

class GeneratorTest extends haxe.unit.TestCase{
  var grammar = __.resource("simple_lang").string();

  public function test(){
    var parser = new stx.parse.jali.term.Term().main().parse(grammar.reader());
    var output = parser.value().force(); 
    switch(output.head()){
      case Data(['Grammar', name]) : 
        var grammar = new Rule(name);
            grammar_handler(output,grammar);
        trace(grammar.toString());
        generate(grammar);
      default : throw "TWATSBANG";
    }
  }
  public function generate(rule:Rule<String>){
    var fields  = [];//FieldDecl
    for(name => impl in rule){
      var next = jali.pack.Lang.fold(
        ()          -> ecall(eident("any"),[]),
        (str,expr)  -> switch(expr){
          case EBlock([]) : ecall(eident(str),[]);
          default         : ecall(eident(str),[expr]);
        },
        (str,expr)  -> ecall(eident(str),[expr]),
        (expr)      -> expr,
        (e0,e1)     -> ecall(eident('seq'),[e0,e1]),
        (e)         -> ecall(eident('rep'),[e]),
        (e0,e1)     -> ecall(eident('alt'),[e0,e1]),
        (e)         -> ecall(eident('opt'),[e]),
        (e)         -> ecall(eident('mem'),[e]),

        (term)      -> Term._.reduce(
          (l,r)   -> {
            //trace('$l $r');
            return switch([l,r]){
              case [e,EBlock([])] : e;
              case [EBlock([]),e] : e;
              default             : eblock([l,r]); 
            }
          },
          (e)     -> switch(prim_from_string(e)){
            case PBool(b)     : econst(CString(Std.string(b)));
            case PInt(b)      : econst(CInt(b));
            case PFloat(b)    : econst(CFloat(b));
            case PString(b)   : econst(CString(b));
            case PNull        : econst(CString('null'));
          },
          ()      -> eblock([]),
          (code)  -> econst(CString(code)),
          term  
        ),
        impl
      );
      var f                 = FunctionDeclA.make([],ereturn(next));
      var field : FieldDecl = FieldDeclA.make(name,f);
      fields.push(field);
    }
    var clazz   = ModuleTypeA.make(rule.name).declare_class(
      fields,
      CTypeA.path('stx.prs.pack.Parse'.split("."))
    );    
  }
  static public function prim_from_string(str:String){
    return switch(str){
      case 'null'                                         : PNull;
      case 'true'                                         : PBool(true);
      case 'false'                                        : PBool(false);
      case __.option(Std.parseInt(_))   => Some(int)      : PInt(int);
      case __.option(Std.parseFloat(_)) => Some(float)    : PFloat(float); 
      default                                             : PString(str);
    }
  }
}
@:forward abstract ClassDeclA(ClassDecl) from ClassDecl to ClassDecl{
  static public function make(module:ModuleTypeA,fields:Array<FieldDecl>,extend,?implement:Array<CType>,is_extern = false):ClassDeclA{
    return {
      name        : module.name,
      meta        : module.meta,
      isPrivate   : module.isPrivate,
      params      : module.params,
      extend      : extend,
      implement   : __.option(implement).defv([]).prj(),
      fields      : fields.prj(),
      isExtern    : is_extern
    }
  }
}
@:forward abstract ModuleTypeA(ModuleType) from ModuleType to ModuleType{
  static public function make(name,?meta,?is_private=false):ModuleTypeA{
    return {
      name        : name,
      meta        : __.option(meta).defv([]),
      isPrivate   : is_private,
      params      : {}
    };
  }
  public function declare_class(fields,?extend,?implement,?is_extern):ClassDeclA{
    return ClassDeclA.make(this,fields,extend,implement,is_extern);
  }
}

abstract ExprA(Expr) from Expr to Expr{
  public function new(self) this = self;
  static public function lift(self:Expr):ExprA return new ExprA(self);
  

  static public function id(str):ExprA{
    return EIdent(str);
  }
  static public function vr(n,?t,?e):ExprA{
    return EVar(n,t,e);
  }
  

  public function prj():Expr return this;
  private var self(get,never):ExprA;
  private function get_self():ExprA return lift(this);
}
class ExprAs{
  static public function econst(c:ConstA):ExprA{
    return EConst(c);
  }
  static public function eident(str:String):ExprA{
    return EIdent(str);
  }
  static public function evar(n : String, ?t : CType, ?e : Expr ):ExprA{
    return EVar(n,t,e);
  }
  static public function eparent(e:Expr):ExprA{
    return EParent(e);
  }
  static public function eblock(arr:Array<Expr>):ExprA{
    return EBlock(arr.prj());
  }
  static public function efield(e,f):ExprA{
    return EField(e,f);
  }
  static public function ebinop(op,e1,e2):ExprA{
    return EBinop( op, e1, e2 );
  }
  static public function eunop(op,prefix,e):ExprA{
    return EUnop( op, prefix, e );
  }
  static public function ecall(e,params):ExprA{
    return ECall(e,params);
  }
  static public function eif(cond,e1,?e2):ExprA{
    return EIf(cond,e1,e2);
  }
  static public function ewhile(e1,e2):ExprA{
    return EWhile(e1,e2);
  }
  static public function efor(v,it,e):ExprA{
    return EFor(v,it,e);
  }
  static public function ebreak():ExprA{
    return EBreak;
  }
  static public function econtinue():ExprA{
    return EContinue;
  }
  static public function efunction(args,e,?name,?ret):ExprA{
    return EFunction(args,e,name,ret);
  }
  static public function ereturn(?e:Expr):ExprA{
    return EReturn(e);
  }
  static public function earray(e:Expr,index:Expr):ExprA{
    return EArray(e,index);
  }
  static public function earray_decl(e:Array<Expr>):ExprA{
    return EArrayDecl( e.prj() );
  }
  static public function enew(cl:String,params:Array<Expr>):ExprA{
    return ENew( cl , params.prj() );
  }
  static public function ethrow(?e:Expr):ExprA{
    return EThrow(e);
  }
  static public function etry(e:Expr,v,t,ecatch):ExprA{
    return ETry(e,v,t,ecatch);
  }
  static public function eobject(fl:Array<Couple<String,Expr>>):ExprA{
    return EObject(fl.map(tp -> {name : tp.fst(), e : tp.snd() }).prj());
  }
  static public function eternary(cond,e1,e2):ExprA{
    return ETernary( cond, e1, e2);
  }
  static public function eswitch(e,cases:Array<Couple<Array<Expr>,Expr>>,?defaultExpr):ExprA{
    return ESwitch(e,cases.map(tp -> { values : tp.fst().prj(), expr : tp.snd() } ).prj(),defaultExpr);
  }
  static public function edo_while(cond:Expr,e:Expr):ExprA{
    return EDoWhile(cond,e);
  }
  static public function emeta(name: String, args:Array<Expr>,e:Expr):ExprA{
    return EMeta(name,args.prj(),e);
  }
  static public function echecktype(e:Expr,t:CType):ExprA{
    return ECheckType(e,t);
  }
}
/*

enum FieldKind {
	KFunction( f : FunctionDecl );
	KVar( v : VarDecl );
}
enum CType {
	CTPath( path : Array<String>, ?params : Array<CType> );
	CTFun( args : Array<CType>, ret : CType );
	CTAnon( fields : Array<{ name : String, t : CType, ?meta : Metadata }> );
	CTParent( t : CType );
	CTOpt( t : CType );
	CTNamed( n : String, t : CType );
}*/


abstract CTypeA(CType) from CType to CType{
  static public function path(path:Array<String>,?params){
    return CTPath(path.prj(),params);
  }
  static public function fun(arr:Array<CType>,ret:CType){
    return CTFun(arr.prj(),ret);
  }
}
abstract FieldDeclA(FieldDecl) from FieldDecl{
  static public function make(name:String,kind:FieldKindA,?access:Array<FieldAccess>){
    return {
      name    : name,
      kind    : kind,
      access  : __.option(access).defv([APublic]).prj(),
      meta    : []
    };
  }
}
abstract FieldKindA(FieldKind) from FieldKind to FieldKind{
  @:from static public function fromKFunction(f:FunctionDeclA):FieldKindA{
    return KFunction(f);
  }
  @:from static public function fromKVar(v:VarDecl):FieldKindA{
    return KVar(v);
  }
}
abstract ArgumentA(Argument) from Argument to Argument{
  static public function make(name:String,?value:Expr, ?t, ?opt = false):ArgumentA{
    return { name : name, t : t, opt : opt, value : value };
  }
}
abstract FunctionDeclA(FunctionDecl) from FunctionDecl to FunctionDecl{
  static public function make(args,expr,?ret):FunctionDeclA{
    return {
      args : args,
      expr : expr,
      ret : ret
    };
  }
  @:to public function toFieldKind():FieldKindA{
    return FieldKindA.fromKFunction(this);
  }
}
abstract ConstA(Const) from Const to Const{
  static public function int(v):ConstA{
    return CInt(v);
  }
  static public function float(v):ConstA{
    return CFloat(v);
  }
  static public function string(v):ConstA{
    return CString(v);
  }
}