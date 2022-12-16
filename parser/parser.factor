
USING: kernel accessors sequences math fry make ascii math.parser aoc2022.util ;
IN: aoc2022.parser

TUPLE: parser string position ;

: <parser> ( string -- parser )
    0 \ parser boa ;

: parser-peek ( parser -- parser ch/f )
    dup [ position>> ] [ string>> ] bi ?nth ;

: parser-pop ( parser -- parser ch/f )
    parser-peek [ [ 1 + ] change-position ] dip ;

: parser-pop* ( parser -- parser )
    parser-pop drop ;

: parser-pop-if* ( parser ch -- parser )
    [ parser-peek ] dip = [ parser-pop* ] when ;

: parser-eof? ( parser -- ? )
    [ position>> ] [ string>> length ] >= ;

: parser-take-while ( ..a parser quot: ( ..a ch -- ..a ? ) -- ..a parser str )
    '[ [ parser-peek _ and-then ] [ parser-pop , ] while ] "" make ; inline

: parse-natural-number ( parser -- parser n/f )
    [ digit? ] parser-take-while string>number ;
