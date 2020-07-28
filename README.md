```haxe
enum LangSum<T>{
  
  App(name:String,?args:Expr<T>);
  Tag(name:String,val:Lang<T>);
  
  One;//what comes in goes out
  Lit(e:Expr<T>);//replace input with this

  Seq(l:Lang<T>,r:Lang<T>);
  Alt(l:Lang<T>,r:Lang<T>);

  Rep(e:Lang<T>);//+
  Opt(e:Lang<T>);//?
  //* == Opt(Rep(_))

  Mem(e:Lang<T>);//recursive rule

  //Not?
  //Has(e:Term<T>,o);//?if else?


  //Put(name:String,val:Lang<T>);?//put in the symbol table
  Get(e:Lang<T>,res:Lang<T>);//parse the left and produce the right
  //Use?
  Sip(e:Lang<T>);//swallow the result

  Def(name:String,lang:Map<String,Lang<T>>);
}
```