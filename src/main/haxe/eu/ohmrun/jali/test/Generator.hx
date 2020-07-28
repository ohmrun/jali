package jali.test;

class Generator{
  static public function grammar_handler(term:Term<String>,grammar:Rule<String>){
    switch(term.tail_body()){
      case Some(_.rest() => Some(rules)) : 
        for (rule in rules){
          method_handler(rule,grammar);
        }
      default : throw "CHANGARANGARANG";
    }
  }
  static public function method_handler(rule:Term<String>,grammar:Rule<String>){
    switch(rule){
      case _.body() => Some(tuple2(_.code() => Some(rule_name),rule_body)) :
        //trace(rule_name);
        //trace(rule_body.prj());             
        var rule_body : Lang<String> = rule_body_rec(rule_body);
        grammar.set(rule_name,rule_body);
      default : throw 'WOBBLO';
    }
  }
  static public function rule_body_rec<T>(v:Term<String>):Lang<String>{
    return switch(v){
      case _.cat() => 
        tuple2(
          _.code()        => Some("Tag"),
          _.data_body()   => Some(tuple2([name,code],rest))
        ) : 
        Tag(name,rule_body_rec(TOf.make().call(code,rest)));
      case _.body() =>
        Some(tuple2(
          _.code()        => Some("Tag"),
          _.code_body()   => Some(tuple2(name,body))
        )) :
        Tag(name,rule_body_rec(body));
      case _.body() => 
        Some(tuple2(
          _.code()  => Some('Mem'),
          body
        )) :
          Mem(rule_body_rec(body));
      case _.code() => Some(tuple2(code,rest)) :
        switch(rest.length){
          case 0 : App(code);
          case 1 :
            var arg = rest[0];
            switch(arg){
              case _.head_only()  => Some(_)                  : App(code,arg);
              case _.data()       => Some(tuple2(data,rest))  :
                trace('hmm');
                throw "FUTTOCKS";
                null;
              case _.rest_body().fmap(_->_.data_only()) => Some(_data) :
                _data.map(App.bind(_,null)).lfold1(Seq).force();
              default : 
                trace(arg.prj());
                throw "FARTISH";
                null;
            }
          //case _.just_code() => Some(code)  
          default : 
            trace(code);
            trace(rest);
            throw "PANT-SCAPE";
            null;
        }
      case _.data_only()    => Some(data) : data.map(App.bind(_,null)).lfold1(Seq).force();
      case _.rest_body()    => Some(body) : rule_body_rec(body);
      default : 
        trace(v);
        throw "WOBBLITO"; 
    }
  }
}