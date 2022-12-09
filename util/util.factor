
USING: strings.parser kernel lexer namespaces strings.parser.private sequences
       strings arrays math.intervals locals math vectors fry math.parser strings
       lists.lazy combinators.short-circuit math.order sequences.extras ;
IN: aoc2022.util

SINGLETON: (util-sentinel)

: parse-raw-string ( -- str )
    lexer get skip-blank
    SBUF" " clone [ lexer get (parse-string) ] keep >string ;

: divide-at ( seq n -- seqs )
    [ head ] [ tail ] 2bi 2array ;

: un2array ( arr -- x y )
    dup length 2 assert=
    [ first ] [ second ] bi ;

: empty-interval? ( i -- ? )
    empty-interval = ;

:: range ( a b step -- arr )
    b a - step /i <vector> a
    [ dup b < ] [ [ suffix! ] keep step + ] while
    drop ;

: remove-last! ( seq -- seq last )
    dup length 1 - swap [ nth ] [ remove-nth! ] 2bi swap ;

: remove-tail! ( seq n -- seq tail )
    [ <vector> ] keep
    [ [ remove-last! ] dip swap suffix! ] times
    reverse! ;

: and-then ( ..a obj1 quot: ( ..a obj1 -- ..a obj2 ) -- ..a obj1/2 )
    over [ call ] [ drop ] if ; inline

: or-else ( ..a obj1 quot: ( ..a obj1 -- ..a obj2 ) -- ..a obj1/2 )
    over [ drop ] [ call ] if ; inline

: or-else* ( ..a obj quot: ( ..a -- ..a obj ) -- ..a obj )
    '[ drop @ ] or-else ; inline

: index-of ( seq quot: ( .. a -- .. ? ) -- index/? )
    find drop ; inline

: suffix!-if-nonempty ( outer inner -- outer )
    dup empty? [ drop ] [ suffix! ] if ;

! Variant of split*-when that includes each element that we split on
! in the following subsequence.
:: split*-when-prefix ( .. seq quot: ( .. elt -- .. ? ) -- .. pieces )
    V{ } clone V{ } clone
    seq [
        dup quot call [
            [ suffix!-if-nonempty V{ } clone ] dip
        ] when
        suffix!
    ] each
    suffix!-if-nonempty ; inline

: char>number ( ch -- i )
    1string string>number ;

:: iterate ( ..a x quot: ( ..a x -- ..a x' ) -- ..a list )
    [ x ] [ x quot call quot iterate ] lazy-cons ; inline

: max-with ( a b quot: ( x -- x ) -- a/b )
    [ 2dup ] dip compare +lt+ = [ nip ] [ drop ] if ; inline

: (<-or-sentinel) ( a b quot: ( x -- x ) -- ? )
    {
        [ 2drop (util-sentinel) = ]
        [ compare +lt+ = ]
    } 3|| ; inline

: (max-with-sentinel) ( a b quot: ( x -- x ) -- a/b )
    pick (util-sentinel) = [
        drop nip
    ] [
        max-with
    ] if ; inline

: (update-ascending-and-check) ( a b quot: ( x -- x ) -- a/b ? )
    [ (max-with-sentinel) ] [ (<-or-sentinel) ] 3bi ; inline

: take-strictly-ascending-prefix-with ( ..a seq quot: ( ..a elt -- ..a key ) -- ..a seq )
     [ (util-sentinel) ] 2dip '[ _ (update-ascending-and-check) ] take-while nip ; inline

: take-only-strictly-ascending-with ( ..a seq quot: ( ..a elt -- ..a key ) -- ..a seq )
    [ (util-sentinel) ] 2dip '[ _ (update-ascending-and-check) ] filter nip ; inline

! Variant of take-while that also includes the element we stopped on.
: stop-at ( .. seq quot: ( .. elt -- .. ? ) -- head-slice )
    [ '[ @ not ] find drop ] keepd swap
    [ 1 + ] [ dup length ] if* head-slice ; inline

SYNTAX: R" parse-raw-string suffix! ;
