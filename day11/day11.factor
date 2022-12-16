
USING: io.files io.encodings.utf8 kernel prettyprint splitting math vectors sequences
       combinators regexp aoc2022.util math.parser accessors strings assocs sorting
       math.functions fry ;
IN: aoc2022.day11

TUPLE: operation lhs op rhs ;

TUPLE: monkey
    { id integer } { items vector } { operation operation }
    { test integer } { true-case integer } { false-case integer }
    { interactions integer } ;

: <operation> ( lhs op rhs -- operation )
    \ operation boa ;

: <monkey> ( id items op test true false -- monkey )
    0 \ monkey boa ;

: read-number-from-line ( line -- n )
    R/ \d+/ first-match string>number ;

: read-all-numbers-from-line ( line -- seq )
    R/ \d+/ all-matching-slices [ string>number ] map ;

: read-items-line ( line -- items )
    read-all-numbers-from-line >vector ;

: read-operation-line ( line -- operation )
    CHAR: = over index 2 + tail " " split un3array
    [ [ string>number ] keep or ] tri@ <operation> ;

: add-item ( monkey item -- )
    [ items>> ] dip suffix! drop ;

DEFER: eval-op

: (eval-arg) ( names arg -- n )
    {
        { operation [ eval-op ] }
        { number [ nip ] }
        { string [ of ] }
    } typecase ;

: eval-op ( names operation -- n )
    [ lhs>> (eval-arg) ] [ rhs>> (eval-arg) ] [ nip op>> ] 2tri
    {
        { "+" [ + ] }
        { "*" [ * ] }
        { "/i" [ /i ] }
        { "mod" [ mod ] }
    } case ;

: eval-monkey-op ( item monkey -- new-item )
    [ "old" swap 1assoc ] dip
    operation>> eval-op ;

: run-monkey-test ( item monkey -- ? )
    test>> divisible? ;

: identify-target-monkey ( item monkey -- new-monkey-id )
    [ run-monkey-test ] keep swap [ true-case>> ] [ false-case>> ] if ;

: eval-monkey-effect ( current-item monkey -- new-monkey-id new-item )
    [ eval-monkey-op ] keep
    [ identify-target-monkey ] keepd ;

: (update-interaction-count) ( monkey -- monkey )
   [ items>> length ] keep [ + ] change-interactions ;

: remove-all-monkey-items ( monkey -- monkey seq )
    dup items>>
    [ 15 <vector> >>items ] dip ;

: do-monkey-turn-for-item ( monkeys monkey item -- )
    swap eval-monkey-effect
    [ swap nth ] dip add-item ;

: do-monkey-turn ( monkeys monkey -- monkeys monkey )
    (update-interaction-count)
    remove-all-monkey-items
    [ [ do-monkey-turn-for-item ] 2keepd ] each ;

: do-full-turn ( monkeys -- monkeys )
    dup [ do-monkey-turn drop ] each ;

: read-monkey ( lines -- monkey )
    {
        [ first read-number-from-line ]
        [ second read-items-line ]
        [ third read-operation-line ]
        [ fourth read-number-from-line ]
        [ 4 swap nth read-number-from-line ]
        [ 5 swap nth read-number-from-line ]
    } cleave <monkey> ;

: lcm-of-monkey-tests ( monkeys -- lcm )
    [ test>> ] map 1 [ lcm ] reduce ;

: append-reduced-worry ( monkey -- )
    [ "/i" 3 <operation> ] change-operation drop ;

: append-modulo-op ( monkey n -- )
    '[ "mod" _ <operation> ] change-operation drop ;

: read-file ( -- monkeys )
    "input11.txt" utf8 file-lines
    { "" } split
    [ read-monkey ] map ;

: part1 ( -- x )
    read-file dup [ append-reduced-worry ] each
    20 [ do-full-turn ] times
    [ interactions>> ] inv-sort-with 2 head-slice [ interactions>> ] map product ;

: part2 ( -- x )
    read-file dup dup lcm-of-monkey-tests '[ _ append-modulo-op ] each
    10,000 [ do-full-turn ] times
    [ interactions>> ] inv-sort-with 2 head-slice [ interactions>> ] map product ;

part1 .
part2 .
