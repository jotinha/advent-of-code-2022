include main.fth

: check ( f -- )
   0= if abort then ;

: is= = check ;

: check-llf-vals-equals ( x1..xn -  )
   size 0 do
      size i - 1- llf-addr llf-value ( x1..xn addr{size-i-1}.val )
      = ( x1..xn-1 xn==val ) 
      check
   loop ;

: check-llf-vals-chain-equals ( x1..xn startaddr n --  )
   2dup 2>r ( x1..xn addr n ) ( R addr n )
   nip nreverse ( xn..x1 ) ( R addr n )
   2r> ( xn..x1 addr n )
   0 do ( xn..x1 addr )
      \ cr 2dup . . cr
      dup llf-value ( xn..x1 addr addr.val ) 
      rot is= ( xn..x2 addr check{addr.val == x1} )
      llf-next-get ( xn..x2 addr=addr.next )
   loop ;

: check-llf-nexti-equals ( i1..in -  )
   size 0 do
      size i - 1- llf-addr llf-next-get ( i1..in addr{size-i-1}.next )
      swap ( i1..in-1 addr.next in )
      \ if in=-1 then treat it differently, get the null address instead
      dup -1 = if drop llf-null else llf-addr then ( i1..in-1 addr.next target=in==-1? llf-null : llf-addr{in} )
      \ 2dup . . cr
      = check
   loop ;

\ initialize llf from the stack
\ sometimes fails for large stacks, so this is now used just for testing
: llf-init ( x1..xn -- )
   7 pSize ! \ TODO: unhack
   size nreverse ( xn..x1 )
   llf  ( xn..x1 addr )
   size 0 do
      tuck ( xn..x2 addr x1 addr )
      ! ( xn..x2 addr ) \ *addr = x1
      1 cells + ( xn..x1 addr+1c )
      dup 1 cells + ( xn..x1 addr+1c addr+2c )
      dup rot ( xn..x1 addr+2c addr+2c addr+1c )
      ! ( xn..x1 addr+2c ) \ *(addr+1c) = addr+2c
   loop ( addr+2c ) 
   \ the last one must point to the first entry
   1 cells - ( addr+2c-1c )
   llf swap ( llf addr+1c )
   !
   \ add a dummy entry at the end
   -1 size llf-addr !
   -1 size llf-addr llf-next-set
   ;   

: llf-show-raw
   size 0 do
      i llf-addr llf-value .
      i llf-addr llf-next-get .
   loop ;

1 1 + 2 = check 

10 20 30 40 50 60 70 llf-init
10 20 30 40 50 60 70 check-llf-vals-equals
1 2 3 4 5 6 0 check-llf-nexti-equals

\ test llf-nright (input is entry at idx 1 with value 20)
1 llf-addr llf-value 20 is=
1 llf-addr 1 llf-nright llf-value 30 is=
1 llf-addr 2 llf-nright llf-value 40 is=
1 llf-addr 5 llf-nright llf-value 70 is=
1 llf-addr 6 llf-nright llf-value 10 is=
1 llf-addr 7 llf-nright llf-value 20 is=
1 llf-addr 14 llf-nright llf-value 20 is=
1 llf-addr 15 llf-nright llf-value 30 is=
1 llf-addr 0 llf-nright llf-value 20 is=  \ n=0

\ test llf-findprev
10 20 30 40 50 60 70 llf-init
1 llf-addr llf-findprev-b @ 10 is=

\ test llf-findprev
10 20 30 40 50 60 70 llf-init
0 llf-addr llf-findprev-b @ 70 is=

\ test llf-findprev
10 20 30 40 50 60 70 llf-init
6 llf-addr llf-findprev-b @ 60 is=


\ test llf-remove  entry at idx 1 with value 20
10 20 30 40 50 60 70 llf-init
1 llf-addr llf-remove
10 20 30 40 50 60 70 check-llf-vals-equals \ the raw values don't change
10 30 40 50 60 70 llf 6 check-llf-vals-chain-equals \ but the sequence does
2 -1 3 4 5 6 0 check-llf-nexti-equals

\ test llf-remove entry at idx 6 with value 70)
10 20 30 40 50 60 70 llf-init
6 llf-addr llf-remove
10 20 30 40 50 60 70 check-llf-vals-equals \ the raw values don't change
10 20 30 40 50 60 llf 6 check-llf-vals-chain-equals \ but the sequence does
1 2 3 4 5 0 -1 check-llf-nexti-equals

\ remove another on the same array (idx=5 val=60)
5 llf-addr llf-remove
10 20 30 40 50 60 70 check-llf-vals-equals \ the raw values don't change
10 20 30 40 50 llf 5 check-llf-vals-chain-equals \ but the sequence does
1 2 3 4 0 -1 -1 check-llf-nexti-equals

\ remove another on the same array (idx=2 val=30)
2 llf-addr llf-remove
10 20 30 40 50 60 70 check-llf-vals-equals \ the raw values don't change
10 20 40 50 llf 4 check-llf-vals-chain-equals \ but the sequence does
1 3 -1 4 0 -1 -1 check-llf-nexti-equals

\ test remove index 0 (because we start the lookup on the first index)
10 20 30 40 50 60 70 llf-init
0 llf-addr llf-remove
10 20 30 40 50 60 70 check-llf-vals-equals \ the raw values don't change
20 30 40 50 60 70  1 llf-addr  6 check-llf-vals-chain-equals \ but the sequence does
-1 2 3 4 5 6 1 check-llf-nexti-equals

\ now, if we remove another one, will find-prev still work?
3 llf-addr llf-findprev-b @ 30 is=

3 llf-addr llf-remove
10 20 30 40 50 60 70 check-llf-vals-equals \ the raw values don't change
20 30 50 60 70  1 llf-addr  5 check-llf-vals-chain-equals \ but the sequence does
-1 2 4 -1 5 6 1 check-llf-nexti-equals

\ test insert
10 20 30 40 50 60 70 llf-init
1 llf-addr llf-remove \ first remove ( we can't simply expand because size is fixed)
10 30 40 50 60 70  llf  6 check-llf-vals-chain-equals \ but the sequence does
1 llf-addr 3 llf-addr llf-insert

10 30 40 20 50 60 70  llf  7 check-llf-vals-chain-equals \ but the sequence does
2 4 3 1 5 6 0 check-llf-nexti-equals

\ test move
10 20 30 40 50 60 70 llf-init
1 llf-addr 1 llf-move-n
10 30 20 40 50 60 70  llf 7 check-llf-vals-chain-equals

1 llf-addr 1 llf-move-n
10 30 40 20 50 60 70  llf 7 check-llf-vals-chain-equals

1 llf-addr 2 llf-move-n
10 30 40 50 60 20 70  llf 7 check-llf-vals-chain-equals

1 llf-addr 3 llf-move-n
10 30 20 40 50 60 70  llf 7 check-llf-vals-chain-equals

2 llf-addr 1 llf-move-n
10 20 30 40 50 60 70  llf 7 check-llf-vals-chain-equals

0 llf-addr 1 llf-move-n
20 10 30 40 50 60 70  1 llf-addr 7 check-llf-vals-chain-equals

1 llf-addr 2 llf-move-n
20 40 50 60 70 10 30 1 llf-addr 7 check-llf-vals-chain-equals

\ move with wrap around

: repeatmove ( addr n -- ) 
   0 do dup 1 llf-move-n loop drop ;

\ moving 6 times (not 7!) is the same as doing nothing
10 20 30 40 50 60 70 llf-init
1 llf-addr 6 repeatmove
10 20 30 40 50 60 70  llf 7 check-llf-vals-chain-equals
1 llf-addr 6 llf-move-n
10 20 30 40 50 60 70  llf 7 check-llf-vals-chain-equals

 \ moving 7 times is the same as moving once
10 20 30 40 50 60 70 llf-init
1 llf-addr 7 repeatmove
10 30 20 40 50 60 70  llf 7 check-llf-vals-chain-equals

10 20 30 40 50 60 70 llf-init
1 llf-addr 7 llf-move-n
10 30 20 40 50 60 70  llf 7 check-llf-vals-chain-equals

\ moving backwards
10 20 30 40 50 60 70 llf-init
1 llf-addr -1 llf-move-n
10 30 40 50 60 70 20 llf 7 check-llf-vals-chain-equals
0 llf-addr -3 llf-move-n
30 40 50 10 60 70 20   2 llf-addr 7 check-llf-vals-chain-equals

10 20 30 40 50 60 70 llf-init
1 llf-addr -6 llf-move-n
10 20 30 40 50 60 70  llf 7 check-llf-vals-chain-equals

\ mix
\ use test data, compare against result in python
1 2 -3 3 -2 0 4 llf-init
mix
4 llf-addr llf-value -2 is=
-2 1 2 -3 4 0 3
4 llf-addr 7 check-llf-vals-chain-equals 



." tests passed" cr