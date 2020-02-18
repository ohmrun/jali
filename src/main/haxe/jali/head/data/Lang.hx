package jali.head.data;

import jali.pack.Lang in LangA;
import jali.pack.Term in TermA;

enum Lang<T>{
  One;
  App(name:String,?args:TermA<T>);
  Tag(name:String,val:LangA<T>);
  
  Lit(e:TermA<T>);//?EQ?
  Seq(l:LangA<T>,r:LangA<T>);
  Rep(e:LangA<T>);
  Alt(l:LangA<T>,r:LangA<T>);
  Opt(e:LangA<T>);

  Mem(e:LangA<T>);
  //Not?
  //Has(e:Term<T>,o);//?if else?
}