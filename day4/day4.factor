
USING: io.encodings.utf8 io.files math.intervals splitting math.parser prettyprint kernel
       sequences aoc2022.util ;
IN: aoc2022.day4

: hyphenated>interval ( str -- i1 )
    "-" split [ string>number ] map un2array [a,b] ;

: parse-line ( line -- ranges )
    "," split [ hyphenated>interval ] map ;

: read-input ( -- lines )
    "input4.txt" utf8 file-lines [ parse-line ] map ;

: one-contains-the-other ( i1 i2 -- ? )
    [ interval-subset? ] [ swap interval-subset? ] 2bi or ;

: part1 ( -- x )
    read-input [ un2array one-contains-the-other ] count ;

: part2 ( -- x )
    read-input [ un2array interval-intersect empty-interval? not ] count ;

part1 .
part2 .
