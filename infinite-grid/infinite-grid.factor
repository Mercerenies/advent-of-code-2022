
USING: accessors aoc2022.grid-like aoc2022.grid hashtables kernel assocs fry
       sequences ;
IN: aoc2022.infinite-grid

TUPLE: infinite-grid default-element { contents hashtable } ;

INSTANCE: infinite-grid grid-like

: <infinite-grid> ( default-element -- grid )
    50 <hashtable> \ infinite-grid boa ;

M: infinite-grid grid-get ( xy grid -- elt )
    [ contents>> at* ] keep swap
    [ drop ] [ nip default-element>> ] if ;

M: infinite-grid grid-set ( elt xy grid -- )
    contents>> set-at ;

M: infinite-grid grid-bounds? ( xy grid -- ? )
    2drop t ;

: grid-all-assigned-positions ( grid -- seq )
    contents>> keys ;

: grid-filter-assigned-positions ( ..a grid quot: ( ..a value -- ..a ? ) -- ..a seq )
    [ [ grid-all-assigned-positions ] keep ] dip '[ _ grid-get @ ] filter ; inline

: grid-all-assigned-values ( grid -- seq )
    contents>> values ;
