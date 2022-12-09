
USING: io.encodings.utf8 io.files kernel math.order math prettyprint arrays sequences sets
       grouping aoc2022.util ;
IN: aoc2022.day3

CONSTANT: all-values "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

: process-line ( line -- line )
    dup length 2 / divide-at ;

: read-input ( -- lines )
    "input3.txt" utf8 file-lines ;

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
