
USING: accessors sequences kernel aoc2022.util locals math combinators.short-circuit
       arrays math.vectors fry ;
IN: aoc2022.grid

CONSTANT: +up+    {  0 -1 }
CONSTANT: +down+  {  0  1 }
CONSTANT: +left+  { -1  0 }
CONSTANT: +right+ {  1  0 }

TUPLE: grid contents ;

: <grid> ( contents -- grid )
    \ grid boa ;

: grid-of-size ( wh initial-value -- grid )
    [ un2array swap ] dip '[ _ _ <repetition> >array ] repeat <grid> ;

: grid-get ( xy grid -- elt )
    [ un2array ] dip contents>> nth nth ;

: grid-set ( elt xy grid -- )
    [ un2array ] dip contents>> nth set-nth ;

:: grid-change ( ..a xy grid quot: ( ..a elt -- ..b elt ) -- ..b )
    xy grid grid-get
    quot call
    xy grid grid-set ; inline

: grid-map ( grid quot: ( a -- a ) -- grid )
    [ contents>> ] dip '[ _ map ] map <grid> ; inline

: grid-find ( elt grid -- xy/f )
    contents>> swap '[ _ swap index ] map-find-with-index
    [ 2array ] [ 2drop f ] if ;

: grid-width ( grid -- i )
    0 swap contents>> nth length ;

: grid-height ( grid -- i )
    contents>> length ;

: grid-dims ( grid -- wh )
    [ grid-width ] [ grid-height ] bi 2array ;

:: (grid-bounds?) ( x y w h -- ? )
    { [ x 0 >= ] [ x w < ] [ y 0 >= ] [ y h < ] } 0&& ;

: grid-bounds? ( xy grid -- ? )
    [ un2array ] dip
    [ grid-width ] [ grid-height ] bi
    (grid-bounds?) ;

: grid-positions ( grid -- seq )
    [ 0 swap grid-width 1 range ] [ 0 swap grid-height 1 range ] bi
    [ 2array ] cartesian-map concat ;

: grid-find-all ( elt grid -- seq )
    dup grid-positions -rot [ swapd grid-get = ] 2curry filter ;

: chessboard-length ( xy -- n )
    [ abs ] map supremum ;

: chessboard-distance ( xy1 xy2 -- n )
    v- chessboard-length ;

: directions ( -- seq )
    +up+ +left+ +down+ +right+ 4array ;
