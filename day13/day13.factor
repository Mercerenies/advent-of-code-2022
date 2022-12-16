
USING: io.files io.encodings.utf8 grouping prettyprint kernel aoc2022.parser sequences
       aoc2022.util make math.order math arrays fry sorting ;
IN: aoc2022.day13

DEFER: parse-element
DEFER: compare-elements

: parser-list-interior ( parser -- parser seq )
    [
        [ parser-peek CHAR: \u{right-square-bracket} = not ] [
            parse-element , CHAR: , parser-pop-if*
        ] while
    ] V{ } make ;

: parse-list ( parser -- parser seq/f )
    parser-peek CHAR: \u{left-square-bracket} = [
        parser-pop* parser-list-interior [ parser-pop* ] dip
    ] and-then* ;

: parse-element ( parser -- parser n/seq/f )
    parse-natural-number [ parse-list ] or-else* ;

: parse-line ( string -- n/seq/f )
    <parser> parse-element nip ;

: read-file ( -- x )
    "input13.txt" utf8 file-lines "" suffix
    3 group [ but-last [ parse-line ] map ] map ;

: wrap-number-in-1array ( obj -- obj )
    dup number? [ 1array ] when ;

: compare-elements ( a b -- <=> )
    2dup [ number? ] bi@ and [ <=> ] [
        [ wrap-number-in-1array ] bi@
        [ compare-elements ] lex-compare
    ] if ;

: distress-packets ( -- seq )
    { { { 2 } } { { 6 } } } ;

: find-distress-packets ( seq -- indices )
    distress-packets swap '[ _ index 1 + ] map ;

: part1 ( -- x )
    read-file [
        [ [ first ] [ second ] bi compare-elements +lt+ = ] [ 1 + ] bi* 2array
    ] map-index
    [ first ] filter [ second ] map sum ;

: part2 ( -- x )
    read-file concat distress-packets append [ compare-elements ] sort
    find-distress-packets product ;

part1 .
part2 .
