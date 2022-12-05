
USING: io.encodings.utf8 io.files kernel math.order math prettyprint arrays sequences sets grouping ;
IN: day3

CONSTANT: all-values "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

: divide-at ( seq n -- seqs )
    [ head ] [ tail ] 2bi 2array ;

: process-line ( line -- line )
    dup length 2 / divide-at ;

: read-input ( -- lines )
    "input3.txt" utf8 file-lines ;

: un2array ( arr -- x y )
    dup length 2 assert=
    [ 0 swap nth ] [ 1 swap nth ] bi ;

: to-priority ( ch -- n )
    dup CHAR: a CHAR: z between?
    [ CHAR: a - 1 + ]
    [ CHAR: A - 27 + ]
    if ;

: part1 ( -- x )
    read-input [
      process-line un2array intersect first to-priority
    ] map sum ;

: part2 ( -- x )
    read-input 3 group [
        all-values [ intersect ] reduce first to-priority
    ] map sum ;

part1 .
part2 .
