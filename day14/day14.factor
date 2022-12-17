
USING: io.files io.encodings.utf8 hashtables accessors aoc2022.grid-like aoc2022.infinite-grid
       prettyprint kernel splitting math.parser grouping aoc2022.util sequences regexp aoc2022.grid
       math.vectors math locals combinators fry ;
IN: aoc2022.day14

SYMBOLS: +wall+ +sand+ ;

CONSTANT: sand-position { 500 0 }

TUPLE: grid-with-floor original-grid { floor-y integer } floor-value ;

INSTANCE: grid-with-floor grid-like

: <grid-with-floor> ( grid floor-y floor-value -- grid )
    \ grid-with-floor boa ;

M:: grid-with-floor grid-get ( xy grid -- elt )
    xy second grid floor-y>> = [
        grid floor-value>>
    ] [
        xy grid original-grid>> grid-get
    ] if ;

M: grid-with-floor grid-bounds? ( xy grid -- ? )
    original-grid>> grid-bounds? ;

: commas>point ( str -- point )
    "," split [ string>number ] map ;

: range>points ( point1 point2 -- point-seq )
    [ un2array ] bi@ swapd [ minmax 1 inclusive-range ] 2bi@ cartesian-product concat ;

: parse-line ( line -- ranges )
    R/ \s->\s/ re-split [ commas>point ] map 2 clump [ un2array range>points ] map concat ;

: put-wall ( grid xy -- grid )
    +wall+ swap pick grid-set ;

: find-max-y ( grid -- y )
    [ ] grid-filter-assigned-positions [ second ] map supremum ;

: position-occupied-relative ( grid sand-xy rel-xy -- grid sand-xy ? )
    over v+ pick grid-get ;

: move-sand ( grid sand-xy -- grid sand-xy moving? )
    {
        { [ {  0 1 } position-occupied-relative not ] [ {  0 1 } v+ t ] }
        { [ { -1 1 } position-occupied-relative not ] [ { -1 1 } v+ t ] }
        { [ {  1 1 } position-occupied-relative not ] [ {  1 1 } v+ t ] }
        [ f ]
    } cond ;

: place-sand ( grid -- grid )
    sand-position [ move-sand ] loop +sand+ spin [ original-grid>> grid-set ] keep ;

: count-sand ( grid -- n )
    original-grid>> grid-all-assigned-values [ +sand+ = ] count ;

: position-atop-floor-level? ( xy grid -- ? )
    [ second ] [ floor-y>> 1 - ] bi* = ;

: sand-atop-floor-level? ( grid -- ? )
    [ original-grid>> grid-all-assigned-positions ] keep '[
        _ [ position-atop-floor-level? ] [ grid-get +sand+ = ] 2bi and
    ] any? ;

: sand-at-source? ( grid -- ? )
    sand-position swap grid-get +sand+ = ;

: add-floor-below ( grid -- grid )
    dup find-max-y 2 + +wall+ <grid-with-floor> ;

: read-file ( -- grid )
    f <infinite-grid>
    "input14.txt" utf8 file-lines [ parse-line ] map concat
    [ put-wall ] each add-floor-below ;

: part1 ( -- x )
    read-file [ dup sand-atop-floor-level? not ] [ place-sand ] while
    count-sand 1 - ;

: part2 ( -- x )
    read-file [ dup sand-at-source? not ] [ place-sand ] while
    count-sand ;

part1 .
part2 .
