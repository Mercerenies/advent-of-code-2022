
USING: io.files io.encodings.utf8 kernel prettyprint math.parser strings sequences
       accessors aoc2022.util aoc2022.grid fry math.vectors math arrays sets vectors
       lists.lazy lists combinators.extras combinators sequences.extras ;
IN: day8

: read-input ( -- grid )
    "input8.txt" utf8 file-lines
    [ [ char>number ] { } map-as ] map <grid> ;

: top-row ( grid -- seq )
    grid-width 0 swap 1 range [ 0 2array ] map ;

: left-column ( grid -- seq )
    grid-height 0 swap 1 range [ 0 swap 2array ] map ;

: bottom-row ( grid -- seq )
    [ top-row ] keep
    grid-height 1 - 0 swap 2array
    '[ _ v+ ] map ;

: right-column ( grid -- seq )
    [ left-column ] keep
    grid-width 1 - 0 2array
    '[ _ v+ ] map ;

: line-of-sight ( grid start delta -- seq )
    '[ _ v+ ] iterate
    swap '[ _ grid-bounds? ] lwhile list>array ;

: filter-tree-visibility ( seq grid -- seq )
    [ grid-get ] curry take-only-strictly-ascending-with ;

: line-of-sight-from-point ( grid start delta -- seq )
    [ line-of-sight ] keepdd filter-tree-visibility ;

: line-of-sight-from-side ( seq grid delta -- seq )
    '[ _ swap _ line-of-sight-from-point ] map ;

: heights-from-line-of-sight ( grid start delta -- seq )
    [ line-of-sight ] keepdd '[ _ grid-get ] map ;

: outside-angles ( grid -- seq )
    {
        [ [ top-row ] keep +down+ line-of-sight-from-side ]
        [ [ bottom-row ] keep +up+ line-of-sight-from-side ]
        [ [ left-column ] keep +right+ line-of-sight-from-side ]
        [ [ right-column ] keep +left+ line-of-sight-from-side ]
    } cleave 4array concat concat ;

: viewing-distance ( grid start delta -- n )
    [ [ swap grid-get ] 2keep ] dip
    heights-from-line-of-sight rest [ dupd > ] stop-at length nip ;

: viewing-distance-each-dir ( grid pos -- seq )
    [ rot viewing-distance ] 2curry
    +up+ +left+ +down+ +right+ 4array swap map ;

: scenic-score ( grid pos -- n )
    viewing-distance-each-dir product ;

: part1 ( -- x )
    read-input outside-angles cardinality ;

: part2 ( -- x )
    read-input
    [ grid-positions ] keep
    [ swap scenic-score ] curry map supremum ;

part1 .
part2 .
