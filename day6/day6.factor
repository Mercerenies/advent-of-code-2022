
USING: io.encodings.utf8 io.files grouping prettyprint sets sequences kernel math ;
IN: aoc2022.day6

: read-input ( -- line )
    "input6.txt" utf8 file-contents ;

: part1 ( -- x )
    read-input 4 clump [ all-unique? ] find drop 4 + ;

: part2 ( -- x )
    read-input 14 clump [ all-unique? ] find drop 14 + ;

part1 .
part2 .
