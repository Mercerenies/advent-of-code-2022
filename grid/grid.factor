
USING: accessors sequences kernel aoc2022.util locals math combinators.short-circuit
       arrays math.vectors ;
IN: aoc2022.grid

CONSTANT: +up+    {  0 -1 }
CONSTANT: +down+  {  0  1 }
CONSTANT: +left+  { -1  0 }
CONSTANT: +right+ {  1  0 }

TUPLE: grid contents ;

: <grid> ( contents -- grid )
    \ grid boa ;

: grid-get ( xy grid -- elt )
    [ un2array ] dip contents>> nth nth ;

: grid-width ( grid -- i )
    0 swap contents>> nth length ;

: grid-height ( grid -- i )
    contents>> length ;

:: (grid-bounds?) ( x y w h -- ? )
    { [ x 0 >= ] [ x w < ] [ y 0 >= ] [ y h < ] } 0&& ;

: grid-bounds? ( xy grid -- ? )
    [ un2array ] dip
    [ grid-width ] [ grid-height ] bi
    (grid-bounds?) ;

: grid-positions ( grid -- seq )
    [ 0 swap grid-width 1 range ] [ 0 swap grid-height 1 range ] bi
    [ 2array ] cartesian-map concat ;

: chessboard-length ( xy -- n )
    [ abs ] map supremum ;

: chessboard-distance ( xy1 xy2 -- n )
    v- chessboard-length ;
