
USING: io.files io.encodings.utf8 kernel prettyprint splitting aoc2022.util
       aoc2022.grid combinators sequences math.parser arrays fry math math.vectors
       accessors math.functions locals sets ;
IN: aoc2022.day9

TUPLE: line direction amount ;

! First knot is the head.
TUPLE: rope knots ;

: char>direction ( char -- dir )
    {
        { CHAR: L [ +left+ ] }
        { CHAR: R [ +right+ ] }
        { CHAR: U [ +up+ ] }
        { CHAR: D [ +down+ ] }
    } case ;

: <line> ( direction amount -- line )
    \ line boa ;

: line>directions ( line -- seq )
    [ amount>> ] [ direction>> ] bi <repetition> ;

: <rope> ( length -- rope )
    { 0 0 } <repetition> >array \ rope boa ;

: rope-length ( rope -- length )
    knots>> length ;

: parse-line ( str -- line )
    " " split un2array [ first char>direction ] [ string>number ] bi* <line> ;

: read-input ( -- dirs )
    "input9.txt" utf8 file-lines [ parse-line line>directions ] map concat ;

: move-toward ( src target -- src1 )
    [ - signum ] keepd swap - ;

: move-toward-vector ( src target -- src1 )
    [ move-toward ] 2map ;

: new-tail-pos ( tail head -- newtail )
    2dup chessboard-distance 1 <= [
        drop
    ] [
        move-toward-vector
    ] if ;

: rope-head ( rope -- head )
    knots>> first ;

: rope-tail ( rope -- head )
    knots>> last ;

: (move-head) ( rope dir -- rope )
    [ dup 0 swap knots>> ] dip [ v+ ] curry replace-nth ;

:: (move-tail-at) ( rope n -- rope )
    rope
    n 1 - rope knots>> nth
    n rope knots>> [ over new-tail-pos ] replace-nth drop ;

: tails ( rope -- seq )
    1 swap rope-length 1 range ;

: move-rope ( rope dir -- rope )
    (move-head) dup tails [ (move-tail-at) ] each ;

: move-rope-and-record-tail ( visited rope dir -- visited rope )
    move-rope [ rope-tail suffix! ] keep ;

: part1 ( -- x )
    V{ { 0 0 } } 2 <rope> read-input
    [ move-rope-and-record-tail ] each
    drop cardinality ;

: part2 ( -- x )
    V{ { 0 0 } } 10 <rope> read-input
    [ move-rope-and-record-tail ] each
    drop cardinality ;

part1 .
part2 .
