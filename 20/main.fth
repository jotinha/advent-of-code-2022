\ implements a linked list. Each entry is a tuple of
\ * value
\ * addr of next entry

variable pSize
: size pSize @ ;
: size++ 1 pSize +! ;
: size0 0 pSize ! ;

variable llf
10002 cells allot  \ allocate space for a max of 5k+1 entries (each entry takes two cells)

: llf-addr ( i -- addr ) 2 * cells llf + ; \ address of entry with index i
: llf-value ( addr -- x ) @ ;
: llf-next ( addr -- addr ) 1 cells + ;  \ address of the pointer to next location (to get the actual location do llf-next @)
: llf-next-get ( addr -- target ) llf-next @ ;
: llf-next-set ( target addr -- ) llf-next ! ;

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
: llf-reset-links ( -- )
   size 0 do
      i 1+ llf-addr i llf-addr llf-next-set ( ) \ addr{i}.next = addr{i+1}
   loop
   \ the last one must point to the first entry
   llf size 1- llf-addr llf-next-set ( ) \ addr{size-1}.next = llf
   ;   

: llf-load ( c-addr -- ) \ also updates size
   r/o open-file throw ( fid )
   size0 \ reset size
   begin
      dup read-line-as-number ( fid d not-eof-flag )
   while ( fid d )
      size llf-addr ! \ addr{size}.value=d
      size++ 
   repeat 
   drop close-file throw
   llf-reset-links
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
\ FIXME: this will fail if the first entry has been deleted
: llf-find0 ( -- addr )
   llf ( addr )
   begin 
      llf-next-get ( addr = addr.next )
      dup @ ( addr.next addr.next.value )
   0= until 
   ;

\ find the address of the previous entry 
\ instead of following the chain of links, follows the linear indices
: llf-findprev ( cur -- addr )
   size 0 do 
      i llf-addr ( cur addr{i} )
      llf-next-get over = ( cur addr{i}.next=cur )
      if 
         drop i llf-addr ( addr{i} )
         leave
       then ( cur )
   loop
   ;

\ remove item, i.e prev.next = addr.next
: llf-remove ( addr )
   dup dup llf-findprev ( addr addr prev )
   swap llf-next-get swap ( addr addr.next prev )
   llf-next-set ( addr ) \ prev.next = addr.next
   -1 swap llf-next-set ( ) \ addr.next = -1
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

s" input" llf-load
ans1 . .\" \b," ans2 . cr

