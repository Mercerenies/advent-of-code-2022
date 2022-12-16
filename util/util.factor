
USING: strings.parser kernel lexer namespaces strings.parser.private sequences
       strings arrays math.intervals locals math vectors fry math.parser strings
       lists.lazy combinators.short-circuit math.order sequences.extras
       classes quotations combinators macros ;
IN: aoc2022.util

SINGLETON: (util-sentinel)

CONSTANT: infinity 1/0.
CONSTANT: -infinity -1/0.

: parse-raw-string ( -- str )
    lexer get skip-blank
    SBUF" " clone [ lexer get (parse-string) ] keep >string ;

: divide-at ( seq n -- seqs )
    [ head ] [ tail ] 2bi 2array ;

: un2array ( arr -- x y )
    dup length 2 assert=
    [ first ] [ second ] bi ;

: un3array ( arr -- x y z )
    dup length 3 assert=
    [ first ] [ second ] [ third ] tri ;

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

: and-then* ( ..a obj quot: ( ..a -- ..a obj ) -- ..a obj )
    '[ drop @ ] and-then ; inline

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

:: replace-nth ( ..a n seq quot: ( ..a elt -- ..a elt ) -- ..a )
    n seq nth quot call n seq set-nth ; inline

: divisible? ( a b -- ? )
    mod 0 = ;

: 1assoc ( k v -- assoc )
    2array 1array ;

: repeat ( ..a n quot: ( ..a -- ..a x ) -- ..a seq )
    [ 0 swap 1 range ] dip '[ drop @ ] map ; inline

: (hide-index) ( quot: ( .. elt -- .. result/f ) -- quot: ( .. i elt -- .. i result/f ) )
    '[ swap _ dip 1 + swap ] ; inline

: map-find-with-index ( .. seq quot: ( .. elt -- .. result/f ) -- .. result i elt )
    [ -1 ] 2dip (hide-index) map-find swapd dup [ [ drop f ] dip ] unless ; inline

: (eq>f) ( obj -- obj/f )
    dup +eq+ = [ drop f ] when ;

: (f>eq) ( obj/f -- obj )
    +eq+ or ;

: lex ( <=> <=> -- <=> )
    over +eq+ = [ nip ] [ drop ] if ;

: (lex-compare) ( .. range seq1 seq2 quot: ( .. a b -- .. <=> ) -- .. <=> )
    '[ [ _ nth ] [ _ nth ] bi @ (eq>f) ] map-find drop (f>eq) ; inline

:: lex-compare ( .. seq1 seq2 quot: ( .. a b -- .. <=> ) -- .. <=> )
    0 seq1 seq2 [ length ] bi@ min 1 range seq1 seq2 quot (lex-compare)
    seq1 seq2 [ length ] compare lex ; inline

: (word>typecheck) ( word -- quot )
   [ dupd execute( -- x ) instance? ] curry ; inline

MACRO: typecase ( assoc -- quot )
    [
        dup array? [
            un2array
            [ (word>typecheck) ] dip
            2array
        ] when
    ] map [ cond ] curry ;

SYNTAX: R" parse-raw-string suffix! ;
