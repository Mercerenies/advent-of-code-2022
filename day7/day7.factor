
USING: io.files io.encodings.utf8 prettyprint splitting grouping sequences vectors
       kernel locals accessors strings math combinators assocs fry arrays math.parser
       sorting aoc2022.util ;
IN: aoc2022.day7

TUPLE: command { name string } { args sequence } { output sequence } ;
TUPLE: file { name string } { size integer } ;
TUPLE: directory { name string } { contents vector } ;
TUPLE: cli-state { folder vector } ;

INSTANCE: directory assoc

M: directory at* ( key dir -- value/f ? )
    contents>> swap '[ name>> _ = ] find swap >boolean ;

M: directory assoc-size ( dir -- n )
    contents>> length ;

M: directory >alist ( dir -- alist )
    contents>> [ [ name>> ] keep 2array ] { } map-as ;

GENERIC: total-size ( obj -- i )

M: file total-size ( file -- i )
    size>> ;

M: directory total-size ( dir -- i )
    contents>> [ total-size ] map sum ;

: remove-file ( dir name -- dir )
    '[ [ name>> _ = not ] filter ] change-contents ;

: put-file ( dir file/dir -- )
    [ name>> remove-file ] keep
    [ contents>> ] dip suffix! drop ;

: put-file-inplace ( dir file/dir -- dir )
    [ dup ] dip put-file ;

: <command> ( name args output -- command )
    \ command boa ;

: <file> ( name size -- file )
    \ file boa ;

: <directory> ( name contents -- dir )
    \ directory boa ;

: parse-command-text ( command -- command-name pieces )
    " " split [ second ] [ 2 tail ] bi ;

: parse-command ( seq -- command )
    [ first parse-command-text ] [ rest-slice ] bi <command> ;

: read-lines ( -- lines )
    "input7.txt" utf8 file-lines [ "$" head? ] split*-when-prefix
    [ parse-command ] map ;

: empty-dir ( name -- dir )
    V{ } clone <directory> ;

: empty-filesystem ( -- filesystem )
    "/" empty-dir ;

: <cli-state> ( -- cli-state )
    V{ } clone \ cli-state boa ;

: cli-up! ( cli-state -- cli-state )
    dup folder>> pop* ;

: cli-goto-root! ( cli-state -- cli-state )
    V{ } clone >>folder ;

: cli-goto-subdir! ( cli-state subfolder -- cli-state )
    [ dup folder>> ] dip suffix! drop ;

: create-new-subdir ( dir name -- subdir )
    empty-dir [ put-file ] keep ;

:: get-or-create-subdir ( dir name -- subdir )
    name dir at [ dir name create-new-subdir ] or-else* ;

: filesystem-get-dir ( filesystem folder -- directory )
    swap [ get-or-create-subdir ] reduce ;

: execute-cd-command! ( filesystem cli-state command -- filesystem cli-state )
    args>> first {
        { ".." [ cli-up! ] }
        { "/" [ cli-goto-root! ] }
        [ cli-goto-subdir! ]
    } case ;

: ls-command-create-row ( dir str -- dir )
    " " split1 swap {
        { "dir" [ empty-dir put-file-inplace ] }
        [ string>number <file> put-file-inplace ]
    } case ;

: execute-ls-command! ( filesystem cli-state command -- filesystem cli-state )
    [ 2dup folder>> filesystem-get-dir ] dip
    output>> [ ls-command-create-row ] each drop ;

: execute-command! ( filesystem cli-state command -- filesystem cli-state )
    dup name>> {
        { "cd" [ execute-cd-command! ] }
        { "ls" [ execute-ls-command! ] }
    } case ;

: each-immediate-directory ( ..a root quot: ( ..a dir -- ..a ) -- ..a )
    [ contents>> [ directory? ] filter ] dip each ; inline

: each-directory ( ..a root quot: ( ..a dir -- ..a ) -- ..a )
    [ call ] [ '[ _ each-directory ] each-immediate-directory ] 2bi ; inline recursive

: all-directories ( root -- seq )
    V{ } clone swap
    [ suffix! ] each-directory ;

: load-filesystem-from-file ( -- filesystem )
    empty-filesystem <cli-state>
    read-lines [ execute-command! ] each
    drop ;

: amount-needed-to-delete ( filesystem -- i )
    total-size 40,000,000 - ;

: get-all-dir-sizes ( filesystem -- seq )
    all-directories [ total-size ] map ;

: find-smallest-above ( n seq -- m/f )
    natural-sort swap '[ _ >= ] find nip ;

: part1 ( -- x )
    load-filesystem-from-file get-all-dir-sizes [ 100,000 <= ] filter sum ;

: part2 ( -- x )
    load-filesystem-from-file [ amount-needed-to-delete ] keep
    get-all-dir-sizes find-smallest-above ;

part1 .
part2 .
