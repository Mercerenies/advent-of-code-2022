
USING: prettyprint io.encodings.utf8 io.files splitting sequences math.parser math.order sorting ;
IN: day1

: read-input ( -- arr )
    "input1.txt" utf8 file-lines { "" } split
    [ [ string>number ] map ] map ;

: part1 ( -- x )
    read-input [ sum ] map supremum ;

: part2 ( -- x )
    read-input [ sum ] map [ >=< ] sort 3 head sum ;

part1 .
part2 .
