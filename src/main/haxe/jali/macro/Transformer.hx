package jali.macro;

import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Context;
import haxe.macro.Compiler;

class Transformer{
  var source : Term<String>;
  public function new(source:Term<String>){
    this.source = source;
  }
  public function deploy(){
    rec(source);
  }
  function rec(source:Term<String>){
    trace(source.prj());
    trace(source.tail().body());
    trace(source.tail().body().flat_map( _ -> _.rest()).map( _ -> _.length ));

    switch(source){
      case _.tail().body().flat_map( _ -> _.rest()) => Some(fields) :
        for(field in fields){
          field_handler(field);
        }
      default :
    }
  }
  function field_handler(source:Term<String>){
    switch(source){
      case _.code().fold(_ -> _.cat(),() ->[])  => [Left('meta'),_] :
      case _.code().fold(_ -> _.cat(),() ->[])  => [Left(name),Right(tail)] : 
        arg_handler(tail.head().fudge());
        switch(tail.tail()){
          default : 
        }
      default : null;
    }
  }
  function arg_handler(source:Term<String>){
    switch(source){
      case _.data_only() => Some(data) :
        trace(data);
      default : throw __.fault().of(MisformedArguments);
    }
  }
}
enum TransformerError{
  MisformedArguments;
}