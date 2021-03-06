(
  SimpleParser (
    ("p_space"      ( sip ( opt ( alt ( id " " id "  " ) ) ) ) )
    ("p_l"          ( p_space sip ( id "(" ) ) )
    ("p_r"          ( p_space sip ( id ")" ) ) ) 
    ("p_bracketed"  ( tag ( "Bracket" ( p_l p_expr p_r ) ) ) )
    ("p_star_id"    ( p_space sip ( id "x" ) ) )
    ("p_plus_id"    ( p_space sip ( id "+" ) ) )
    ("p_int"        ( p_space tag ("Num" ( regex "[0-9]+") ) ) )
    ("p_expr"       ( mem ( alt ( p_mult p_plus p_int p_bracketed ) ) ) )
    ("p_mult"       ( p_space tag ("Mult" ( p_expr p_star_id p_expr ) ) ) )
    ("p_plus"       ( p_space tag ("Plus" ( p_expr p_plus_id p_expr ) ) ) )
    ("main"         ( p_expr ) )
  )
)