variable ns
5000 constant size

: addr-- ( addr -- addr' ) 1 cells - ;
: array-init ( n addr -- ) 1 + cells allot ;
: array-push ( x1..xn n addr -- ) 
    over \ x1..xn n addr n
    cells + \ x1..xn n addr'=addr+(n cells) 
    swap \ x1..xn addr' n
    0 do \ x1..xn addr
        tuck \ x1..xn-1 addr xn addr
        ! \ x1..xn-1 addr 
        addr--
    loop ;

: ns-put ( v i -- ) 
    tuck \ i v i
    cells ns + ! \ i
    dup size + \ (i i + size)
    cells ns + ! 
    ;

: ns-get ( i -- v idx)
    dup \ i i
    cells ns + @ \ i v
    swap \ v i
    5000 +
    cells ns + @
    ;

: fill-ns 
    dup \ x1..xn n n
    ns ! \ x1..xn n
    0 do \ x1..xn
        ns i cells + !
    loop ; 

\ variable ns 7 cells allot \ initialize array
\ 1 2 -3 3 -2 0 4
\ 7 ns array-push 

\ : show-ns  0 do ns i cells + ? loop ;
\ 7 show-ns
