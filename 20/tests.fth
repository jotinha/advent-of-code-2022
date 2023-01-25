include main.fth

: nreverse ( x1...xn n -- xn..x1 ) \ reverse the stack
   0 DO I ROLL LOOP ;

: check ( f -- )
   0= if abort then ;

: is= = check ;

: check-dll-vals-equals ( x1..xn -  )
   size 0 do
      size i - 1- dll-at getval ( x1..xn addr{size-i-1}.val )
      = ( x1..xn-1 xn==val ) 
      check
   loop ;

: check-dll-vals-chain-equals ( x1..xn startaddr n --  )
   2dup 2>r ( x1..xn addr n ) ( R addr n )
   nip nreverse ( xn..x1 ) ( R addr n )
   2r> ( xn..x1 addr n )
   0 do ( xn..x1 addr )
      \ cr 2dup . . cr
      dup getval ( xn..x1 addr addr.val ) 
      rot is= ( xn..x2 addr check{addr.val == x1} )
      getnext ( xn..x2 addr=addr.next )
   loop ;

: check-dll-nexti-equals ( i1..in -  )
   size 0 do
      size i - 1- dll-at getnext ( i1..in addr{size-i-1}.next )
      swap ( i1..in-1 addr.next in )
      \ if in=-1 then treat it differently
      dup -1 = if  ( i1..in-1 addr.next in )
         is=
      else
         dll-at is=
      then ( i1..in-1 target=in==-1? check{addr.next==-1} : check{addr.next==dll-at{in}} )
      \ 2dup . . cr
   loop ;

: dll-init-test
   \ this file contains the data 10 20 30 40 50 60 70
   s" testcase" dll-load ;

: dll-show-raw
   size 0 do
      i dll-at . ." : "
      i dll-at getval .
      i dll-at getnext .
      i dll-at getprev .
      cr
   loop ;


: dll-ls ( -- )
   cr
   dll size 0 do ( addr )
      dup ? ." -> " ( addr ) \ print value at addr
      getnext ( addr=addr.next )
   loop  
   drop cr ;

1 1 + 2 = check 

dll-init-test
10 20 30 40 50 60 70 check-dll-vals-equals
1 2 3 4 5 6 0 check-dll-nexti-equals

\ test dll-nright (input is entry at idx 1 with value 20)
1 dll-at getval 20 is=
1 dll-at 1 dll-nright getval 30 is=
1 dll-at 2 dll-nright getval 40 is=
1 dll-at 5 dll-nright getval 70 is=
1 dll-at 6 dll-nright getval 10 is=
1 dll-at 7 dll-nright getval 20 is=
1 dll-at 14 dll-nright getval 20 is=
1 dll-at 15 dll-nright getval 30 is=
\ 1 dll-at 0 dll-nright getval 20 is=  \ n=0 no longer supported

\ test dll-remove  entry at idx 1 with value 20
dll-init-test
1 dll-at dll-remove
10 20 30 40 50 60 70 check-dll-vals-equals \ the raw values don't change
10 30 40 50 60 70 dll 6 check-dll-vals-chain-equals \ but the sequence does
2 -1 3 4 5 6 0 check-dll-nexti-equals

\ test dll-remove entry at idx 6 with value 70)
dll-init-test
6 dll-at dll-remove
10 20 30 40 50 60 70 check-dll-vals-equals \ the raw values don't change
10 20 30 40 50 60 dll 6 check-dll-vals-chain-equals \ but the sequence does
1 2 3 4 5 0 -1 check-dll-nexti-equals

\ remove another on the same array (idx=5 val=60)
5 dll-at dll-remove
10 20 30 40 50 60 70 check-dll-vals-equals \ the raw values don't change
10 20 30 40 50 dll 5 check-dll-vals-chain-equals \ but the sequence does
1 2 3 4 0 -1 -1 check-dll-nexti-equals

\ remove another on the same array (idx=2 val=30)
2 dll-at dll-remove
10 20 30 40 50 60 70 check-dll-vals-equals \ the raw values don't change
10 20 40 50 dll 4 check-dll-vals-chain-equals \ but the sequence does
1 3 -1 4 0 -1 -1 check-dll-nexti-equals

\ test remove index 0 (because we start the lookup on the first index)
dll-init-test
0 dll-at dll-remove
10 20 30 40 50 60 70 check-dll-vals-equals \ the raw values don't change
20 30 40 50 60 70  1 dll-at  6 check-dll-vals-chain-equals \ but the sequence does
-1 2 3 4 5 6 1 check-dll-nexti-equals

3 dll-at dll-remove
10 20 30 40 50 60 70 check-dll-vals-equals \ the raw values don't change
20 30 50 60 70  1 dll-at  5 check-dll-vals-chain-equals \ but the sequence does
-1 2 4 -1 5 6 1 check-dll-nexti-equals

\ test insert
dll-init-test
1 dll-at dll-remove \ first remove ( we can't simply expand because size is fixed)
10 30 40 50 60 70  dll  6 check-dll-vals-chain-equals \ but the sequence does
1 dll-at 3 dll-at dll-insert

10 30 40 20 50 60 70  dll  7 check-dll-vals-chain-equals \ but the sequence does
2 4 3 1 5 6 0 check-dll-nexti-equals

\ test move
dll-init-test
1 dll-at 1 dll-move-n
10 30 20 40 50 60 70  dll 7 check-dll-vals-chain-equals

1 dll-at 1 dll-move-n
10 30 40 20 50 60 70  dll 7 check-dll-vals-chain-equals

1 dll-at 2 dll-move-n
10 30 40 50 60 20 70  dll 7 check-dll-vals-chain-equals

1 dll-at 3 dll-move-n
10 30 20 40 50 60 70  dll 7 check-dll-vals-chain-equals

2 dll-at 1 dll-move-n
10 20 30 40 50 60 70  dll 7 check-dll-vals-chain-equals

0 dll-at 1 dll-move-n
20 10 30 40 50 60 70  1 dll-at 7 check-dll-vals-chain-equals

1 dll-at 2 dll-move-n
20 40 50 60 70 10 30 1 dll-at 7 check-dll-vals-chain-equals

\ move with wrap around

: repeatmove ( addr n -- ) 
   0 do dup 1 dll-move-n loop drop ;

\ moving 6 times (not 7!) is the same as doing nothing
dll-init-test
1 dll-at 6 repeatmove
10 20 30 40 50 60 70  dll 7 check-dll-vals-chain-equals
1 dll-at 6 dll-move-n
10 20 30 40 50 60 70  dll 7 check-dll-vals-chain-equals

 \ moving 7 times is the same as moving once
dll-init-test
1 dll-at 7 repeatmove
10 30 20 40 50 60 70  dll 7 check-dll-vals-chain-equals

dll-init-test
1 dll-at 7 dll-move-n
10 30 20 40 50 60 70  dll 7 check-dll-vals-chain-equals

\ moving backwards
dll-init-test
1 dll-at -1 dll-move-n
10 30 40 50 60 70 20 dll 7 check-dll-vals-chain-equals
0 dll-at -3 dll-move-n
30 40 50 10 60 70 20   2 dll-at 7 check-dll-vals-chain-equals

dll-init-test
1 dll-at -6 dll-move-n
10 20 30 40 50 60 70  dll 7 check-dll-vals-chain-equals

\ mix
\ use test data, compare against result in python
s" test" dll-load
mix
4 dll-at getval -2 is=
-2 1 2 -3 4 0 3
4 dll-at 7 check-dll-vals-chain-equals 

." tests passed" cr