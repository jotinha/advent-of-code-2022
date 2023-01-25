\ implements a doubly linked list. Each entry is a tuple of
\ * value
\ * addr of next entry
\ * addr of prev entry

variable pSize
: size pSize @ ;
: size++ 1 pSize +! ;
: size0 0 pSize ! ;

variable dll
15000 cells allot  \ allocate space for a max of 5k (each entry takes three cells)

: dll-at ( i -- addr ) 3 * cells dll + ; \ address of entry with index i
: getval ( addr -- x ) @ ;
: getnext ( addr -- target ) cell+ @ ;
: getprev ( addr -- target ) cell+ cell+ @ ;
: setnext ( target addr -- ) cell+ ! ;
: setprev ( target addr -- ) cell+ cell+ ! ;
: dll-first ( -- addr ) dll ;
: dll-last ( -- addr ) size 1- dll-at ;

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

\ sets the forwards links, can also be used to unmix back to the original order
: dll-reset-links ( -- )
   size 0 do
      i 1+ dll-at i dll-at setnext ( ) \ addr{i}.next = addr{i+1}
      i 1- dll-at i dll-at setprev ( ) \ addr{i}.prev = addr{i-1}
   loop
   \ the last one must point to the first entry
   dll-first dll-last setnext ( ) \ addr{size-1}.next = dll
   \ the first one must link to the last entry
   dll-last dll-first setprev ( ) \ last.prev = first
   ;   

: dll-load ( c-addr -- ) \ also updates size
   r/o open-file throw ( fid )
   size0 \ reset size
   begin
      dup read-line-as-number ( fid d not-eof-flag )
   while ( fid d )
      size dll-at ! \ addr{size}.value=d
      size++ 
   repeat 
   drop close-file throw
   dll-reset-links
   ;

\ get the address of the item that is n places to the right of entry at addr
\ doesn't work with negative indices
: dll-nright ( addr n -- addr )
   dup 0<= if abort then ( addr n ) \ if (n <= 0) abort
   0 do ( addr ) \ for i=0:size
      getnext ( addr=addr.next )
   loop ;

\ find addr of entry with value 0
\ FIXME: this will fail if the first entry has been deleted
: dll-find0 ( -- addr )
   dll-first ( addr )
   begin 
      getnext ( addr = addr.next )
      dup @ ( addr.next addr.next.value )
   0= until 
   ;

\ remove item, i.e 
\ x.prev.next = x.next
\ x.next.prev = x.prev
\ x.next = x.prev = -1
: dll-remove { addr -- }
   addr getnext ( addr.next )
   addr getprev ( addr.next addr.prev )
   setnext ( ) \ addr.prev.next = addr.next
   addr getprev ( addr.prev )
   addr getnext ( addr.prev addr.next )
   setprev ( ) \ addr.next.prev = addr.prev

   -1 addr setnext \ addr.next = -1
   -1 addr setprev \ addr.prev = -1
   ;


\ insert item `addr` after item `prev` and before `next`
: dll-insert-between { addr prev next -- }
   addr prev setnext \ prev.next = addr
   addr next setprev \ next.prev = addr
   prev addr setprev \ addr.prev = prev
   next addr setnext \ addr.next = next
   ;

\ insert item `addr` after item `prev`
: dll-insert ( addr prev -- )
   dup getnext ( addr prev prev.next )
   dll-insert-between ;

: dll-move-n ( addr n -- )
   size 1- mod ( addr n=n%{size-1} )
   dup 0<> if 
      over swap ( addr addr n )
      dll-nright ( addr prev=dll-nright{addr,n} )
      swap dup ( prev addr addr )
      dll-remove ( prev addr )
      swap dll-insert ( )
   else 
      2drop
   then
   ;

: mix ( -- )
   size 0 do
      i dll-at getval ( val )
      i dll-at swap ( addr n )
      dll-move-n ( )
   loop ;     

: get-grooves ( -- x )
   dll-find0 ( addr{val=0} ) \ start at address of entry with val 0
   3 0 do
      1000 dll-nright ( addr=addr+1000 ) \ walk 1000 places
      dup @ ( addr val )
      swap ( val addr )
   loop ( val1 val2 val3 addr )
   drop + + ( val1 + val2 + val3 )
   ;

: ans1 
   mix
   get-grooves
   ;

: ans2 
   \ first we need to multiply all values by 811589153
   \ for 64-bit forth, the precision should be enough, otherwise use mod
   dll-reset-links \ reset mix
   
   size 0 do
      i dll-at getval 811589153 * ( addr{i}.val * key )
      i dll-at ! 
   loop
   
   10 0 do  \ mix 10 times
      mix 
   loop
   
   get-grooves
   ;

s" input" dll-load
ans1 . .\" \b," ans2 . cr

