package jali.head.data;

import jali.pack.Tail in TailA;
import jali.pack.Term in TermA;
import jali.pack.Head in HeadA;

enum Term<T>{
  TOf(head:HeadA<T>,rest:TailA<T>);
}