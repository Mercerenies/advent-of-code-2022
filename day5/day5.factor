
USING: io.encodings.utf8 io.files splitting prettyprint accessors aoc2022.rawstring kernel memoize
       pcre sequences math.parser assocs locals math vectors strings math.matrices sequences.extras ;
IN: aoc2022.day5

TUPLE: move amount source destination ;

MEMO: move-regexp ( -- regexp )
    R" move (?<amount>\d+) from (?<source>\d+) to (?<destination>\d+)" <compiled-pcre> ;

:: range ( a b step -- arr )
    b a - step /i <vector> a
    [ dup b < ] [ [ suffix! ] keep step + ] while
    drop ;

: parse-move ( str -- move )
    move-regexp findall first
    [ "amount" of ] [ "source" of ] [ "destination" of ] tri
    [ string>number ] tri@
    \ move boa ;

: parse-stack ( str -- row )
    1 over length 4 range [
        over nth 1string
    ] map nip ;

: parse-stacks ( strs -- arr )
    1 head*
    [ parse-stack ] map flip [ reverse [ " " = not ] take-while >vector ] map ;

: read-input ( -- positions moves )
    "input5.txt" utf8 file-lines
    { "" } split1
    [ parse-stacks ]
    [ [ parse-move ] map ]
    bi* ;

: remove-last! ( seq -- seq last )
    dup length 1 - swap [ nth ] [ remove-nth! ] 2bi swap ;

: remove-tail! ( seq n -- seq tail )
    [ <vector> ] keep
    [ [ remove-last! ] dip swap suffix! ] times
    reverse! ;

:: move-reversed ( amount source destination -- )
    source amount remove-tail! nip
    reverse
    destination swap append! drop ;

: apply-move-reversed ( positions move -- positions )
    dupd
    [ nip amount>> ] [ source>> 1 - swap nth ] [ destination>> 1 - swap nth ] 2tri
    move-reversed ;

:: move ( amount source destination -- )
    source amount remove-tail! nip
    destination swap append! drop ;

: apply-move ( positions move -- positions )
    dupd
    [ nip amount>> ] [ source>> 1 - swap nth ] [ destination>> 1 - swap nth ] 2tri
    move ;

: part1 ( -- x )
    read-input swap [ apply-move-reversed ] reduce
   [ last ] map concat ;

: part2 ( -- x )
    read-input swap [ apply-move ] reduce
   [ last ] map concat ;

part1 .
part2 .
