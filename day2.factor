
USING: splitting sequences kernel prettyprint io.encodings.utf8 io.files assocs accessors
       combinators locals math.order math ;
IN: day2

SYMBOLS: +rock+ +paper+ +scissors+ ;

TUPLE: line opponent self ;

: interpret-line ( str -- arr )
    " " split [ first ] [ second ] bi line boa ;

: read-input ( -- arr )
    "input2.txt" utf8 file-lines [ interpret-line ] map ;

: translate ( table line -- line )
    [ over at ] change-opponent
    [ over at ] change-self
    nip ;

:: compare-rps ( a b -- <=> )
    {
        { [ a b = ] [ +eq+ ] }
        { [ a +rock+ = b +paper+ = and ] [ +lt+ ] }
        { [ a +paper+ = b +scissors+ = and ] [ +lt+ ] }
        { [ a +scissors+ = b +rock+ = and ] [ +lt+ ] }
        [ +gt+ ]
    } cond ;

: value-of-throw ( throw -- n )
    {
        { +rock+ 1 }
        { +paper+ 2 }
        { +scissors+ 3 }
    } at ;

: value-of-round ( line -- n )
    [
        self>> value-of-throw
    ] [
        [ self>> ] [ opponent>> ] bi
        compare-rps { { +gt+ 6 } { +eq+ 3 } { +lt+ 0 } } at
    ] bi + ;

: outcome>throw ( outcome opponent -- throw )
    [ { +eq+ +lt+ +gt+ } index ]
    [ { +paper+ +rock+ +scissors+ } index ]
    bi* + 3 mod { +paper+ +rock+ +scissors+ } nth ;

: determine-move ( line -- line )
    [ [ self>> ] [ opponent>> ] bi outcome>throw ] keep
    swap >>self ;

: part1 ( -- x )
    read-input
    {
        { "A" +rock+ } { "B" +paper+ } { "C" +scissors+ }
        { "X" +rock+ } { "Y" +paper+ } { "Z" +scissors+ }
    }
    [ swap translate value-of-round ] curry map sum ;

: part2 ( -- x )
    read-input
    {
        { "A" +rock+ } { "B" +paper+ } { "C" +scissors+ }
        { "X" +lt+ } { "Y" +eq+ } { "Z" +gt+ }
    }
    [ swap translate determine-move value-of-round ] curry map sum ;

part1 .
part2 .
