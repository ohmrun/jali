package jali.pack;

import jali.head.data.Term in TermT;
import stx.prs.head.data.JsValue;

abstract Term<T>(TermT<T>) from TermT<T> to TermT<T>{
  public function new(self:TermT<T>) this = self; 
  static public function parse(str:String):ParseResult<String,Term<String>>{
    return new stx.parse.jali.term.Term().parse(str.reader());
  }
  public function head(){
    return switch(this){
      case TOf(hd, _) : hd;
    }
  }
  public function term():Option<Head<T>>{
    return cat().snd().ds().is_defined() ? None : cat().fst();
  }
  public function tail(){
    return switch(this){
      case TOf(_, xs) : __.option(xs).defv([]);
    }
  }
  public function tail_body(){
    return switch(this){
      case TOf(_, tail ) : tail.body();
    }
  }
  public function snoc(that:Term<T>):Term<T>{
    return switch(this){
      case TOf(Data(data),rest) : TOf(Rest,[this,that]);
      case TOf(Rest,null)       : TOf(Rest,[that]);
      case TOf(Rest,rest)       : TOf(Rest,rest.ds().snoc(that).prj());
      case TOf(Code(_),rest)    : TOf(Rest,[this,that]);
    }
  }
  public function both(that:Term<T>):Term<T>{
    return TOf(Rest,[this,that]);
  }
  @:from static public function fromTArray<T>(arr:Array<T>):Term<T>{
    return TOf(Data(arr),[]);
  }
  @:from static public function fromTermArray<T>(arr:Array<Term<T>>):Term<T>{
    return TOf(Rest,arr);
  }
  public function toArray():Array<Dynamic>{
    return switch(self){
      case TOf(Code(name),rest)   : ([name]:Array<Dynamic>).concat(rest.map(_ -> _.toArray()));
      case TOf(Rest,rest)         : rest.map( _ -> _.toArray());
      case TOf(Data(data),rest)   : (data:Array<Dynamic>).snoc(rest.map( _ -> _.toArray()));
    }
  }
  public function toJsonic():Jsonic<T>{
    var stamp = () -> ({
      type : null,
      rest : []
    }:Jsonic<T>);

    function rec(v:TermT<T>):Jsonic<T> return switch v {
      case TOf(Rest, rest): 
        var out = stamp();
            out.type = JRest;
            out.rest = __.option(rest).defv([]).map(rec);
            out;
      case TOf(Data(data), rest):
        var out = stamp();
            out.type = JData;
            out.data = data;
            out.rest = __.option(rest).defv([]).map(rec);
            out;
      case TOf(Code(code), rest):
        var out = stamp();
            out.type = JCode;
            out.code = code;
            out.rest = __.option(rest).defv([]).map(rec);
            out;
    }
    return rec(this);
  }
  static public function fromArray(arr:Array<Dynamic>):Term<Dynamic>{
    return switch (arr.length){
      case 0  : TOf(Rest,[]);
      case 1  : 
        var sub : Array<Dynamic> = arr[0];
        if(sub.length == 0) { 
          TOf(Data([]),[]);
        } else {
          fromArray(sub);
        }
      default : 
        var sub : Array<Dynamic> = arr.prj().pop();
        if(sub.length == 0) { 
          TOf(Data(arr),[]);
        }else{
          TOf(Data(arr),[fromArray(sub)]);
        }
    }
  }
  static public function fromJsValue(val:JsValue<String>):Term<String>{
    return switch (val){
      case JsObject(record) :
          TOf.make().rest(
            record.map(
              (tp) -> switch(tp){
                case tuple2(l,r) : TOf(Code(l),[fromJsValue(r)]);
              }
            )
          );
      case JsArray(array) :
          TOf.make().rest(
            array.map(_ -> fromJsValue(_))
          );
      case JsData(x) : TOf.make().datum(x,__);
    }
  }
  static public function fromMap<V>(map:StdMap<String,V>):Term<V>{
    var parts : Array<Term<V>> = [];
    for( key => val in map ){
      parts.prj().push(
        TOf.make().call_data(key,[val])
      );
    }
    return TOf(Rest,parts);
  }
  static public function map<T,U>(fn:T->U,expr:Term<T>){
    return switch expr {
      case TOf(Rest,null)           : TOf(Rest,[]);
      case TOf(Rest,_rest)          : TOf(Rest,_rest.map(map.bind(fn)));
      case TOf(Data(_data),_rest)   : TOf(Data(_data.map(fn)),_rest.map(map.bind(fn)));
      case TOf(Code(_code),_rest)   : TOf(Code(_code),_rest.map(map.bind(fn)));
    }
  }
  static public function t_reduce<T,Z>(unit:Void->Z,pure:T->Z,plus:Z->Z->Z,?code:String->Option<T->Z>,expr:Term<T>):Z{
    code = __.option(code).defv((_) -> None);
    var f = t_reduce.bind(unit,pure,plus,code);
    return switch expr {
      case TOf(Rest,null)           : unit();
      case TOf(Rest,_rest)          : _rest.map(f).ds().lfold(plus,unit());
      case TOf(Data(_data), _rest)  : _rest.map(f).ds().lfold(plus,_data.map(pure).lfold(plus,unit()));
      case TOf(Code(_code), _rest)  : _rest.map(t_reduce.bind(unit,code(_code).defv(pure),plus,code)).ds().lfold(plus,unit());
    }
  }
  static public function optimise<T>(expr:Term<T>):Term<T>{
    return mod(
      (x:Term<T>) -> switch(x){
        case TOf(hd,null) : TOf(hd,[]);
        case TOf(hd,subs) : subs.ds().all(
          (sub) -> switch(sub){
            case TOf(Rest,_)      : true;
            default               : false;
          }
        ).if_else(
          () -> TOf(hd,subs.ds().map_filter(
            (term) -> switch(term){
              case TOf(Rest,arr)  : Some(arr);
              default             : None;
            }
          ).fmap(_ -> _)),
          () -> TOf(hd,subs)
        );
        default : x;
      },
      expr
    );
  }
  static public function codeify(expr:Term<String>):Term<String>{
    return mod(
      (x) -> switch(x){
        case TOf(Data([str]),_rest)   : TOf(Code(str),_rest);
        default                       : x;
      },
      expr
    );
  }
  static public function mod<T>(fn:Term<T> -> Term<T>,expr:Term<T>):Term<T>{
    return fn(switch expr {
      case TOf(Rest,null)             : TOf(Rest,[]);
      case TOf(Rest,_rest)            : TOf(Rest,_rest.map(mod.bind(fn)));
      case TOf(Data(_data), _rest)    : TOf(Data(_data),_rest.map(mod.bind(fn)));
      case TOf(Code(_code), _rest)    : TOf(Code(_code),_rest.map(mod.bind(fn)));
    });
  }
  static public function walk<T>(fn:Term<T> -> Void,expr:Term<T>):Void{
    fn(expr);
    switch expr{
      case TOf(_,_rest)           :
        for (term in _rest){
          walk(fn,term);
        }
      default : 
    };
  }
  @:arrayAccess
  public function access(str:T):Term<T>->Term<T>{
    return (that:Term<T>) -> {
      return TOf(Data([str]),[this,that]);
    }
  }
  @:op(A.B)
  public function resolve(str:String):Term<T>->Term<T>{
    return (that:Term<T>) -> {
      return TOf(Code(str),[this,that]);
    }
  }
  public function toStringCompact(){
    function rec(v:Term<T>,n:Int=0):String{
      var t = '';
      for (i in 0...n){
        t = t + ' ';
      }
      return switch(v){
        case null           : '';
        case TOf(Rest,null) : '';
        case TOf(Rest,rest) : 
          '$t' + rest.map(rec.bind(_,++n)).join('$t');
        case TOf(Data(data),rest) : 
          var head = data.map(Std.string).join(" ");
          '$head$t' + rest.map(rec.bind(_,++n)).join('$t');
        case TOf(Code(code),rest) : 
          '$code$t' + rest.map(rec.bind(_,++n)).join('$t');
      }
    }
    return rec(this);
  }
  public function toString(){
    function rec(v:Term<T>,n:Int=0):String{
      var t = '';
      for (i in 0...n){
        t = t + '  ';
      }
      return switch(v){
        case TOf(Rest,null) : '';
        case TOf(Rest,rest) : 
          '$t' + rest.map(rec.bind(_,++n)).join('\n$t');
        case TOf(Data(data),rest) : 
          var head = data.map(Std.string).join(" ");
          '$head\n$t' + rest.map(rec.bind(_,++n)).join('\n$t');
        case TOf(Code(code),rest) : 
          '$code\n$t' + rest.map(rec.bind(_,++n)).join('\n$t');
      }
    }
    return '\n' + rec(this);
  }
  public function traverse(){

  }
  public function prj():TermT<T>{
    return this;
  }
  private var self(get,never):Term<T>;
  private function get_self():Term<T> return lift(this);
  static public function lift<T>(expr:TermT<T>):Term<T>{
    return new Term(expr);
  }
  static public function unit<T>() return TOf(Rest,[]);

  public function cat(){
    return toTuple2();
  }
  public function toTuple2():Tuple2<Head<T>,Tail<T>>{
    return switch(this){
      case TOf(head,rest)       : tuple2(head,rest);
    }
  }
  public function just_code():Option<String>{
    return cat().fst().code();
  }
  public function code_body():Option<Tuple2<String,Term<T>>>{
    return body().fmap(
      tp -> __.lbump()(tp.lmap( head -> head.code()))
    );
  }
  public function body():Option<Tuple2<Head<T>,Term<T>>>{
    return __.through().fn()
      .pair((_:Tail<T>) -> _.body())
      .into(
        (head,opt) -> opt.map(tuple2.bind(head))
      )(toTuple2());
  }
  public function just_data():Option<Array<T>>{
    return cat().fst().data();
  }
  public function data():Option<Tuple2<Array<T>,Tail<T>>>{
    return 
      ((head:Head<T>) -> head.data()).fn()
      .pair(__.through())
      .into((l,r) -> l.map(tuple2.bind(_,r)))
      (cat());
  }
  public function data_body():Option<Tuple2<Array<T>,Term<T>>>{
    return body().fmap(
      tp -> __.lbump()(tp.lmap( head -> head.data()))
    );
  }
  public function code():Option<Tuple2<String,Tail<T>>>{
    return 
      ((head:Head<T>) -> head.code()).fn()
      .pair(__.through())
      .into((l,r) -> l.map(tuple2.bind(_,r)))
      (cat());
  }
  public function rest():Option<Tail<T>>{
    var tup = cat();
      return tup.fst().is_term() ? Some(tup.snd()) : None;
  }
  public function rest_body():Option<Term<T>>{
    var tup = cat();
      return tup.fst().is_term() && tup.snd().length == 1 ? Some(tup.snd()[0]) : None;
  }
  static public function reduce<T,Z>(plus:Z->Z->Z,pure:T->Z,unit:Void->Z,code:String->Z,self:TermT<T>){
    var f   = reduce.bind(plus,pure,unit,code);
    var fun = (rest:Tail<T>) -> rest.map(f).ds().lfold1(plus).def(unit);
    return switch self {
      case null                   : unit();
      case TOf(Rest, null)        : unit();
      case TOf(Rest, _rest)       : fun(_rest);
      case TOf(Code(_code),_rest) : plus(code(_code),fun(_rest));
      case TOf(Data(_data),_rest) : plus(_data.map(pure).lfold1(plus).def(unit),fun(_rest));
    }
  }
}