\ implements a linked list. Each entry is a tuple of
\ * value
\ * addr of next entry

variable llf
10002 cells allot  \ allocate space for 5k+1 entries (each entry takes two cells)

: llf-addr ( i -- addr ) 2 * cells llf + ; \ address of entry with index i
: llf-value ( addr -- x ) @ ;
: llf-next ( addr -- addr ) 1 cells + ;  \ address of the pointer to next location (to get the actual location do llf-next @)
: llf-next-get ( addr -- target ) llf-next @ ;
: llf-next-set ( target addr -- ) llf-next ! ;

s" input" r/o open-file throw
constant fid 

: read-line-as-number ( fid -- n f )
   pad 20 rot ( c-str u fid )
   read-line throw ( nchars not-eof-flag )
   if 
      pad swap ( c-addr nchars )
      s>number? ( d1 d2 f )
      0= throw ( d1 d2 ) \ throw if flag=0
      drop ( d1 ) \ not interested in d2
      -1 ( d flag=-1 )
   else
      drop 0 0 ( d=0 flag=0 ) \ indicate eof
   then ;

: llf-load ( -- n )
   5001 0 do \ max of 5k lines
      fid read-line-as-number ( d not-eof-flag )
      0= ( d ) 
      if drop i leave then \ if eof return i
      i llf-addr ! ( ) \ addr{i}.value=d
   loop 
   \ add the null entry at the end
   -1 over llf-addr ! ( n ) \ *addr{n}=-1 
   ;


llf-load
constant size
cr ." Read " size . ." lines" cr

: llf-show-raw
   size 1+ 0 do
      i llf-addr llf-value .
      i llf-addr llf-next-get .
   loop ;

\ sets the forwards links, can also be used to unmix back to the original order
: llf-reset-links ( -- )
   size 0 do
      i 1+ llf-addr i llf-addr llf-next-set ( ) \ addr{i}.next = addr{i+1}
   loop
   \ the last one must point to the first entry
   llf size 1- llf-addr llf-next-set ( ) \ addr{size-1}.next = llf
   \ the null entry points nowhere
   -1 size llf-addr llf-next-set ( ) \ addr{size}.next = -1
   ;
llf-reset-links

: llf-null ( -- addr ) size llf-addr ;
: llf-next-set-null ( addr -- ) 
   llf-null ( addr nulladdr )
   swap ( nulladdr addr )
   llf-next-set ( ) \ addr.next = nulladdr
   ;


: llf-ls ( -- )
   cr
   llf size 0 do ( addr )
      dup ? ." -> " ( addr ) \ print value at addr
      llf-next-get ( addr=addr.next )
   loop  
   drop cr ;

\ llf-ls

: nreverse ( x1...xn n -- xn..x1 ) \ reverse the stack
   0 DO I ROLL LOOP ;

\ initialize llf from the stack
\ sometimes fails for large stacks, so this is now used just for testing
: llf-init ( x1..xn -- )
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

\ get the address of the item that is n places to the right of entry at addr
\ doesn't work with negative indices
: llf-nright ( addr n -- addr )
   dup 0<= if ( addr n ) \ if (n <= 0)
      drop
   else
      0 do ( addr ) \ for i=0:size
         llf-next-get ( addr=addr.next )
      loop
   then ;

\ find addr of entry with value 0
: llf-find0 ( -- addr )
   llf ( addr )
   begin 
      llf-next-get ( addr = addr.next )
      dup @ ( addr.next addr.next.value )
   0= until 
   ;

\ cr ." 0 is at pos " llf-find0 . cr

\ cr ." the item that is 5 places to the right of the start is "
\ llf 5 llf-nright ? cr

\ find the address of the previous entry ( requires a linear search )
: llf-findprev ( cur -- addr )
   llf ( cur addr ) \ this fails if entry 0 has been removed
   size 0 do 
      2dup llf-next-get = ( cur addr cur==addr.next )
      if leave then 
      llf-next-get
   loop
   nip ( addr )
   ;

\ find the address of the previous entry 
\ instead of following the chain of links, follows the linear indices
: llf-findprev-b ( cur -- addr )
   size 0 do 
      i llf-addr ( cur addr{i} )
      llf-next-get over = ( cur addr{i}.next=cur )
      if 
         drop i llf-addr ( addr{i} )
         leave
       then ( cur )
   loop
   ;

\ cr ." the item to the left of the start is "
\ llf llf-findprev ? cr

\ remove item, i.e prev.next = addr.next
: llf-remove ( addr )
   dup dup llf-findprev-b ( addr addr prev )
   swap llf-next-get swap ( addr addr.next prev )
   llf-next-set ( addr ) \ prev.next = addr
   llf-next-set-null ( ) 
   ;

\ insert item `addr` after item `prev`
\ addr.next = prev.next
\ prev.next = addr
: llf-insert ( addr prev -- )
   2dup ( addr prev addr prev )
   llf-next-get ( addr prev addr prev.next ) 
   swap llf-next-set ( addr prev ) \ addr.next = prev.next
   llf-next-set ( ) \ prev.next = addr
   ;

: llf-move-n ( addr n -- )
   size 1- mod ( addr n=n%{size-1} )
   dup 0> if 
      over swap ( addr addr n )
      llf-nright ( addr prev=llf-nright{addr,n} )
      swap dup ( prev addr addr )
      llf-remove ( prev addr )
      swap llf-insert ( )
   else 
      2drop
   then
   ;

\ ." mixing "
: mix ( -- )
   size 0 do
      i llf-addr llf-value ( val )
      i llf-addr swap ( addr n )
      llf-move-n ( )
   loop ;     

: get-grooves ( -- x )
   llf-find0 ( addr{val=0} ) \ start at address of entry with val 0
   3 0 do
      1000 llf-nright ( addr=addr+1000 ) \ walk 1000 places
      dup @ ( addr val )
      swap ( val addr )
   loop ( val1 val2 val3 addr )
   drop + + ( val1 + val2 + val3 )
   ;

: ans1 
   mix
   get-grooves
   ;

: llf-values-multiply ( x -- )
   size 0 do
      dup i llf-addr llf-value *  ( x x*addr{i}.val )
      i llf-addr ! ( x ) \ addr.val = addr.val*x
   loop drop ;

: ans2 
   \ first we need to multiply all values by 811589153
   \ for 64-bit forth, the precision should be enough, otherwise use mod
   llf-reset-links \ reset mix
   811589153 llf-values-multiply
   10 0 do mix loop \ mix 10 times
   get-grooves
   ;


ans1 . ans2 .

