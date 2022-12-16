
USING: io.files io.encodings.utf8 kernel sequences math.parser splitting prettyprint
       accessors assocs fry math combinators aoc2022.util make io ;
IN: aoc2022.day10

TUPLE: machine x ;

TUPLE: instruction opcode args ;

: <machine> ( -- machine )
    1 \ machine boa ;

: should-draw? ( machine hpos -- ? )
    [ x>> ] dip - abs 1 <= ;

: <instruction> ( opcode args -- instruction )
    \ instruction boa ;

: <noop> ( -- instruction )
    "noop" { } <instruction> ;

: parse-instr ( line -- instr )
    " " split [ first ] [ rest [ string>number ] map ] bi <instruction> ;

: instr-time ( instr -- n )
    opcode>> {
        { "addx" 2 }
        { "noop" 1 }
    } at ;

: execute-instr-instant ( machine instr -- machine )
    dup opcode>> {
        { "addx" [ args>> first '[ _ + ] change-x ] }
        { "noop" [ drop ] }
    } case ;

! Pad an instruction with enough noops to account for the time spent
! running the instruction.
: pad-with-noops ( instr -- seq )
    [ instr-time 1 - <noop> <repetition> ] keep suffix ;

: pad-instrs ( seq -- newseq )
    [ pad-with-noops ] map concat ;

: read-input ( -- dirs )
    "input10.txt" utf8 file-lines [ parse-instr ] map ;

: get-signal-strength ( x-values time -- strength )
    [ swap nth ] keep 2 + * ; ! +2 because we're 0-indexed (so +1) and we want the start of the next cycle (+1)

! Okay, the puzzle says to get the signal strength *before* the 20th,
! 60th, 100th, 140th, 180th, and 220th cycles. However, our program
! outputs the strength *after* cycles, so we really want 19th, 59th,
! etc. And our code is 0-based, so we want indices 18, 58, ...
: cycles-of-interest ( -- seq )
    18 219 40 range ;

: write-to-buf ( machine n -- )
    [ 40 divisible? [ CHAR: \n , ] when ] keep
    40 mod should-draw? CHAR: # CHAR: \u{space} ? , ;

: run-one-cycle ( machine n instr -- machine n )
    swap [ execute-instr-instant ] dip 1 + [ write-to-buf ] 2keep ;

: part1 ( -- x )
    <machine> read-input pad-instrs
    [ execute-instr-instant dup x>> ] map nip
    [ swap get-signal-strength ] curry cycles-of-interest swap map sum ;

: part2 ( -- x )
    <machine> 0 read-input pad-instrs
    [ CHAR: # , [ run-one-cycle ] each ] SBUF" " make
    2nip ;

part1 .
part2 write
