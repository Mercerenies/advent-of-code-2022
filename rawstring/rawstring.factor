
USING: strings.parser kernel lexer namespaces strings.parser.private sequences strings ;
IN: aoc2022.rawstring

: parse-raw-string ( -- str )
    lexer get skip-blank
    SBUF" " clone [ lexer get (parse-string) ] keep >string ;

SYNTAX: R" parse-raw-string suffix! ;
