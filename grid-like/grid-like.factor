
USING: accessors locals kernel ;
IN: aoc2022.grid-like

MIXIN: grid-like

GENERIC: grid-get ( xy grid -- elt )

GENERIC: grid-set ( elt xy grid -- )

GENERIC: grid-bounds? ( xy grid -- ? )

:: grid-change ( ..a xy grid quot: ( ..a elt -- ..b elt ) -- ..b )
    xy grid grid-get
    quot call
    xy grid grid-set ; inline
