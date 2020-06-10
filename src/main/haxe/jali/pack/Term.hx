package jali.pack;

import stx.fail.PathParseFailure;
import hxjsonast.Json;

import hxjsonast.Json.JsonValue;

enum TermSum<T>{
  TOf(head:Head<T>,rest:Tail<T>);
}
@:using(jali.pack.Term.TermLift)
abstract Term<T>(TermSum<T>) from TermSum<T> to TermSum<T>{
  public function new(self:TermSum<T>) this = self; 
  static public var _(default,never) = TermLift;

  static public function make<T>():Constructor<T>                               return TOf;                               
  static public function unit<T>():Term<T>                                      return TOf(Rest,[]);
  static public function lift<T>(self:TermSum<T>):Term<T>                       return new Term(self);
  static public function parse(string:String) 
      return new stx.parse.Jali()
        .parse(string.reader())
        .fold(
          _ -> __.success(_.with),
          e -> __.failure(__.fault().of(E_Fs_Path(E_Path_Parse(MalformedSource(e)))))
        );

  @:from static public function fromTArray<T>(arr:Array<T>):Term<T>{
    return TOf(Data(arr),[]);
  }
  @:from static public function fromTermArray<T>(arr:Array<Term<T>>):Term<T>{
    return TOf(Rest,arr);
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
  // static public function fromJsonSum(val:JsonSum<String>):Term<String>{
  //   return switch (val){
  //     case JsObject(record) :
  //         TOf.make().rest(
  //           record.map(
  //             __.decouple(
  //               (l,r) -> TOf(Code(l),[fromJsonSum(r)])
  //             )
  //           )
  //         );
  //     case JsArray(array) :
  //         TOf.make().rest(
  //           array.map(_ -> fromJsonSum(_))
  //         );
  //     case JsData(x) : TOf.make().datum(x,__);
  //   }
  // }
  
  static public function fromMap<V>(map:StdMap<String,V>):Term<V>{
    var parts : Array<Term<V>> = [];
    for( key => val in map ){
      parts.prj().push(
        TOf.make().code_data(key,[val])
      );
    }
    return TOf(Rest,parts);
  }

  @:arrayAccess public function access(str:T):Term<T>->Term<T>{
    return (that:Term<T>) -> TOf(Data([str]),[this,that]);
  }
  @:op(A.B) public function resolve(str:String):Term<T>->Term<T>{
    return (that:Term<T>) -> TOf(Code(str),[this,that]);
  }

  public function cat():Couple<Head<T>,Tail<T>>                 return _.toCouple(self);

    
  public function prj():TermSum<T> return this;
  private var self(get,never):Term<T>;
  private function get_self():Term<T> return lift(this); 
}
// private typedef TermInnerApi<T> = {
//   function head(self:Term<T>)                 : Head<T>;
//   function tail(self:Term<T>)                 : Tail<T>;

//   function body(self:Term<T>)                 : Option<Term<T>>;
//   function body_head(self:Term<T>)            : Option<Head<T>>;


//   function code_only(self:Term<T>)            : Option<String>;
//   function code(self:Term<T>)                 : Option<Couple<String,Tail<T>>>;
//   function code_body(self:Term<T>)            : Option<Couple<String,Term<T>>>;

//   function data_only(self:Term<T>)            : Option<Array<T>>;
//   function data(self:Term<T>)                 : Option<Couple<Array<T>,Tail<T>>>;
//   function data_body(self:Term<T>)            : Option<Couple<Array<T>,Term<T>>>;

//   function rest(self:Term<T>)                 : Option<Tail<T>>;
//   function rest_body(self:Term<T>)            : Option<Term<T>>;

// }
class TermLift{
  //static public function into<T,U>(self:Term<T>,lift:TermInnerApi<T> -> (Term<T> -> U)):U{
   // return lift(null)(self);
  //}
  static public function head<T>(self:Term<T>){
    return switch(self){
      case TOf(hd, _) : hd;
    }
  }
  static public function tail<T>(self:Term<T>){
    return switch(self){
      case TOf(_, xs) : __.option(xs).defv([]);
    }
  }

  static public function code_only<T>(self:Term<T>):Option<String>{
    return self.cat().fst().code();
  }
  static public function code<T>(self:Term<T>):Option<Couple<String,Tail<T>>>{
    return Dual.unit().first(
      (head:Head<T>) -> head.code()
    ).into(
      (l:Option<String>,r:Tail<T>) -> l.map(__.couple.bind(_,r))
    )(self.cat());
  }
  static public function code_body<T>(self:Term<T>):Option<Couple<String,Term<T>>>{
    return self.body().flat_map(
      tp -> __.lbump(tp.lmap( head -> head.code()))
    );
  }

  static public function body<T>(self:Term<T>):Option<Couple<Head<T>,Term<T>>>{
    return __.through().fn()
      .pair((_:Tail<T>) -> _.body())
      .into(
        (head,opt) -> opt.map(__.couple.bind(head))
      )(toCouple(self));
  }
  static public function body_head<T>(self:Term<T>):Option<Head<T>>{
    return self.cat().snd().is_defined() ? None : self.cat().fst();
  }

  static public function data_only<T>(self:Term<T>):Option<Array<T>>{
    return self.cat().snd().is_defined() ? None : self.cat().fst().data();
  }
  static public function data<T>(self:Term<T>):Option<Couple<Array<T>,Tail<T>>>{
    return 
      ((head:Head<T>) -> head.data()).fn()
      .pair(__.through())
      .then(__.lbump)
      (self.cat());
  }
  static public function data_body<T>(self:Term<T>):Option<Couple<Array<T>,Term<T>>>{
    return self.body().flat_map(
      tp -> __.lbump(tp.lmap( head -> head.data()))
    );
  }
  static public function endata<T>(self:Term<T>,that:Array<T>){
    return switch(self){
      case TOf(Data(data),rest) : TOf(Data(data.concat(that)),rest);
      case TOf(Rest,null)       : TOf(Data(that),Tail.unit());
      case TOf(Rest,rest)       : TOf(Data(that),rest);
      case TOf(Code(_),rest)    : TOf(Data(that),[self]);
    }
  }
  static public function concat<T>(self:Term<T>,that:Term<T>):Term<T>{
    return switch(self){
      case TOf(Data(data),rest) : TOf(Rest,[self,that]);
      case TOf(Rest,null)       : TOf(Rest,[that]);
      case TOf(Rest,rest)       : TOf(Rest,rest.snoc(that).prj());
      case TOf(Code(_),rest)    : TOf(Rest,[self,that]);
    }
  }
  static public function subtree<T>(self:Term<T>,that:Term<T>):Term<T>{
    return switch(self){
      case TOf(Data(data),rest) : TOf(Data(data),rest.snoc(that));
      case TOf(Rest,null)       : TOf(Rest,[that]);
      case TOf(Rest,rest)       : TOf(Rest,rest.snoc(that).prj());
      case TOf(Code(code),rest) : TOf(Code(code),rest.snoc(that));
    }
  }
  static public function both<T>(self:Term<T>,that:Term<T>):Term<T>{
    return TOf(Rest,[self,that]);
  }
  
  
  static public function rest<T>(self:Term<T>):Option<Tail<T>>{
    var tup = self.cat();
      return tup.fst().is_term() ? Some(tup.snd()) : None;
  }
  static public function rest_body<T>(self:Term<T>):Option<Term<T>>{
    var tup = self.cat();
      return tup.fst().is_term() && tup.snd().length == 1 ? Some(tup.snd()[0]) : None;
  }

  static public function toArray<T>(self:Term<T>):Array<Dynamic>{
    return switch(self){
      case TOf(Code(name),rest)   : ([name]:Array<Dynamic>).concat(rest.map(_ -> _.toArray()));
      case TOf(Rest,rest)         : rest.map( _ -> _.toArray());
      case TOf(Data(data),rest)   : (data:Array<Dynamic>).snoc(rest.map( _ -> _.toArray()));
    }
  }
  static public function toJsonic<T>(self:Term<T>):Jsonic<T>{
    var stamp = () -> ({
    }:Jsonic<T>);

    function rec(v:Term<T>):Jsonic<T> return switch v {
      case TOf(Rest, rest): 
        var out = stamp();
            //out.type = JRest;
            var rest = __.option(rest).defv([]).map(rec);
            if(rest.is_defined()){
              out.rest = rest;
            }
            
            out;
      case TOf(Data(data), rest):
        var out = stamp();
            //out.type = JData;
            out.data = data;
            var rest = __.option(rest).defv([]).map(rec);
            if(rest.is_defined()){
              out.rest = rest;
            }
            
            out;
      case TOf(Code(code), rest):
        var out = stamp();
            //out.type = JCode;
            out.code = code;
            var rest = __.option(rest).defv([]).map(rec);
            if(rest.is_defined()){
              out.rest = rest;
            }
            
            out;
    }
    return rec(self);
  }
  static public function map<T,U>(self:Term<T>,fn:T->U){
    return switch self {
      case TOf(Rest,null)           : TOf(Rest,[]);
      case TOf(Rest,_rest)          : TOf(Rest,_rest.map(map.bind(_,fn)));
      case TOf(Data(_data),_rest)   : TOf(Data(_data.map(fn)),_rest.map(map.bind(_,fn)));
      case TOf(Code(_code),_rest)   : TOf(Code(_code),_rest.map(map.bind(_,fn)));
    }
  }
  static public function t_reduce<T,Z>(self:Term<T>,unit:Void->Z,pure:T->Z,plus:Z->Z->Z,?code:String->Option<T->Z>):Z{
    code = __.option(code).defv((_) -> None);
    var f = t_reduce.bind(_,unit,pure,plus,code);
    return switch self {
      case TOf(Rest,null)           : unit();
      case TOf(Rest,_rest)          : _rest.map(f).lfold(plus,unit());
      case TOf(Data(_data), _rest)  : _rest.map(f).lfold(plus,_data.map(pure).lfold(plus,unit()));
      case TOf(Code(_code), _rest)  : _rest.map(t_reduce.bind(_,unit,code(_code).defv(pure),plus,code)).lfold(plus,unit());
    }
  }
  static public function optimise<T>(self:Term<T>):Term<T>{
    return mod(
      self,
      (x:Term<T>) -> switch(x){
        case TOf(hd,null) : TOf(hd,[]);
        case TOf(hd,subs) : subs.all(
          (sub) -> switch(sub){
            case TOf(Rest,_)      : true;
            default               : false;
          }
        ).if_else(
          () -> TOf(hd,subs.map_filter(
            (term) -> switch(term){
              case TOf(Rest,arr)  : Some(arr);
              default             : None;
            }
          ).flat_map(_ -> _)),
          () -> TOf(hd,subs)
        );
        default : x;
      }
    );
  }
  static public function codeify(self:Term<String>):Term<String>{
    return mod(
      self,
      (x) -> switch(x){
        case TOf(Data([str]),_rest)   : TOf(Code(str),_rest);
        default                       : x;
      }
    );
  }
  static public function mod<T>(self:Term<T>,fn:Term<T> -> Term<T>):Term<T>{
    return fn(switch self {
      case TOf(Rest,null)             : TOf(Rest,[]);
      case TOf(Rest,_rest)            : TOf(Rest,_rest.map(mod.bind(_,fn)));
      case TOf(Data(_data), _rest)    : TOf(Data(_data),_rest.map(mod.bind(_,fn)));
      case TOf(Code(_code), _rest)    : TOf(Code(_code),_rest.map(mod.bind(_,fn)));
    });
  }
  static public function walk<T>(self:Term<T>,fn:Term<T> -> Void):Void{
    fn(self);
    switch self{
      case TOf(_,_rest)           :
        for (term in _rest){
          walk(term,fn);
        }
      default : 
    };
  }
  static public function reduce<T,Z>(self:Term<T>,plus:Z->Z->Z,pure:T->Z,unit:Void->Z,code:String->Z){
    var f   = reduce.bind(_,plus,pure,unit,code);
    var fun = (rest:Tail<T>) -> rest.map(f).lfold1(plus).def(unit);
    return switch self {
      case null                   : unit();
      case TOf(Rest, null)        : unit();
      case TOf(Rest, _rest)       : fun(_rest);
      case TOf(Code(_code),_rest) : plus(code(_code),fun(_rest));
      case TOf(Data(_data),_rest) : plus(_data.map(pure).lfold1(plus).def(unit),fun(_rest));
    }
  }
  static public function toStringCompact<T>(self:Term<T>){
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
    return rec(self);
  }
  static public function toString<T>(self:Term<T>){
    function rec(v:Term<T>,n:Int=1):String{
      var t = '';
      for (i in 0...n){
        t = t + '  ';
      }
      var f     = rec.bind(_,++n);
      var lvl   = (arr) -> '\n$t' + arr.join('\n$t');
      var f0    = (arr) -> lvl(arr.map(f));
      return switch(v){
        case TOf(Rest,null)                           : '';
        case TOf(Rest,tail) if(!tail.is_defined())    : '';
        case TOf(Rest,rest) : 
          '$t'    + f0(rest);
        case TOf(Data(data),tail) if(!tail.is_defined()) : 
          var head = data.map(Std.string).join(" ");
          '$head';
        case TOf(Data(data),rest) : 
          var head = data.map(Std.string).join(" ");
          '$head ' + f0(rest);
        case TOf(Code(code),rest) : 
          '$code ' + f0(rest);
      }
    }
    return '\n' + rec(self);
  }
  static public function toCouple<T>(self:Term<T>):Couple<Head<T>,Tail<T>>{
    return switch(self){
      case TOf(head,rest)       : __.couple(head,rest);
    }
  }
}