package jali.head.data;

import jali.pack.Term in TermA;

enum Head<T>{
  Rest;
  Data(data:Array<T>);
  Code(code:String);
}