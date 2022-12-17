
USING: io.files io.encodings.utf8 prettyprint kernel aoc2022.grid sequences combinators aoc2022.util
       math arrays accessors math.vectors namespaces locals math.order aoc2022.grid-like ;
IN: aoc2022.day12

TUPLE: terrain grid start-position end-position ;
SYMBOL: terrain-data

: <terrain> ( grid start end -- terrain )
    \ terrain boa ;

: with-terrain ( ..a terrain quot: ( ..a -- ..b ) -- ..b )
    terrain-data swap with-variable ; inline

: get-current-terrain ( -- terrain )
    terrain-data get ;

: terrain-get ( xy -- elt )
    terrain-data get grid>> grid-get ;

: terrain-start ( -- start )
    terrain-data get start-position>> ;

: terrain-end ( -- end )
    terrain-data get end-position>> ;

: terrain-dims ( -- wh )
    terrain-data get grid>> grid-dims ;

: terrain-bounds? ( xy -- ? )
    terrain-data get grid>> grid-bounds? ;

: translate-elevation ( char -- char )
    {
        { CHAR: S [ CHAR: a ] }
        { CHAR: E [ CHAR: z ] }
        [ ]
    } case ;

: find-start-and-end ( grid -- start end )
    [ CHAR: S swap grid-find ] [ CHAR: E swap grid-find ] bi ;

: can-travel ( src-height dest-height -- ? )
    - -1 >= ;

:: can-travel-pos ( src dest -- ? )
    src dest [ terrain-bounds? ] bi@ and
    [ src dest [ terrain-get ] bi@ can-travel ] and-then* ;

: (dynamic-grid-set-end-to-zero) ( dynamic-grid -- dynamic-grid )
    [ 0 terrain-end ] dip [ grid-set ] keep ;

: dynamic-grid ( -- dynamic-grid )
    terrain-dims infinity grid-of-size (dynamic-grid-set-end-to-zero) ;

: take-better ( current new -- changed? current/new )
    [ > ] [ min ] 2bi ;

:: update-position-based-on ( dynamic-grid src-pos dest-pos -- changed? )
    src-pos dest-pos can-travel-pos [
        dest-pos dynamic-grid grid-get 1 +
        src-pos dynamic-grid [ swap take-better ] grid-change
    ] [ f ] if ;

: update-position ( dynamic-grid pos -- dynamic-grid pos changed? )
    directions [
      over v+ [ update-position-based-on ] 2keepd rot
    ] map [ ] any? ;

: update-all-positions ( dynamic-grid -- dynamic-grid changed? )
    dup grid-positions [
        update-position nip
    ] map [ ] any? ;

: read-file ( -- terrain )
    "input12.txt" utf8 file-lines <grid>
    [ find-start-and-end ] keep
    [ translate-elevation ] grid-map
    -rot <terrain> ;

: part1 ( -- x )
    read-file [
       dynamic-grid
       [ update-all-positions ] loop
       terrain-start swap grid-get
    ] with-terrain ;

: part2 ( -- x )
    read-file [
        dynamic-grid
        [ update-all-positions ] loop
        CHAR: a get-current-terrain grid>> grid-find-all
        [ over grid-get ] map infimum nip
    ] with-terrain ;

part1 .
part2 .
