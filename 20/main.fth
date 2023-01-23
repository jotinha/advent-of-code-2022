\ loads the data file and pushes it to stack, last value pushed is total number of lines
: read-numbers-file ( c-addr -- x1...xn cnt)
    r/o open-file throw ( fid ) 
    0 swap ( cnt=0 fid) 
    begin
        dup ( cnt fid fid ) 
        pad 20 rot ( cnt fid c-str u fid )
        read-line throw ( cnt fid nchars not-eof-flag )
    while ( cnt fid nchars )
        pad swap ( cnt fid c-addr nchars )
        s>number? ( cnt fid d1 d2 f ) 
        2drop ( cnt fid d1 ) \ we just want the first part of the double precision number
        rot 1 + ( fid d1 cnt+1)
        rot ( d1 cnt fid )
    repeat
    drop ( x1...xn cnt fid)
    close-file throw ( x1..xn cnt)
    ;
 
s" test" read-numbers-file
constant size

\ implements a double linked list. Each entry is a tuple of
\ * value
\ * index of previous value
\ * index of next value

variable ll 
size 3 * cells allot 

: addr ( i -- addr ) 3 * cells ll + ;
: val ( i -- val) addr @ ;

: preva ( i -- addr) addr 1 cells + ;
: nexta ( i -- addr) addr 2 cells + ;

: previ ( i -- i ) preva @ ; 
: nexti ( i -- i ) nexta @ ; 

: ll-init ( x1..xn -- )
    size 0 do
        size i - 1 - addr !  \ put x at position size -i -1 (because the stack is inverted)
        i 1 - size mod i preva ! \ put i-1 % size at index i
        i 1 + size mod i nexta ! \ put i+1 % size at index i
    loop ;

: ll-show ( -- )
    size 0 do
        i nexti i val i previ
        . ." <- " . ." -> " . cr
    loop ;

: memswap ( addr1 addr2 -- ) 
    2dup ( addr1 addr2 addr1 addr2 )
    @ swap @ swap ( addr1 addr2 val1 val2)
    rot rot ( addr1 val2 addr2 val1)
    swap ! swap !
    ;

: ll-walkvaluesf ( -- x1...xn)
    0 ( k = 0)
    size 0 do
        dup ( k k)
        val swap ( val k )
        nexti ( val data[k].nexti )
    loop drop ;

\ same but walk in backwards direction (still starts at index 0)
: ll-walkvaluesb ( -- x1...xn ) 0 size 0 do dup val swap previ loop drop ;

\ find the index i n places to the right of entry at j
: ll-findi-nright ( j n -- idx )
    0 do ( j ) \ for i=0:size
        nexti ( j=dj.nexti)
    loop ;

\ find idx of entry with value 0
: ll-find0 ( -- i )
    0 ( i = 0 )
    begin 
        1+ dup 
    val 0= until 
    ;

: surround ( i -- i.preva i.nexta)
    dup preva swap nexta ;

\ remove item at position i
\ di.prev.next = di.next
\ di.next.prev = di.prev
: ll-remove ( i -- ) 
    dup dup nexti ( i i di.nexti)
    swap previ ( i di.nexti di.previ )
    nexta ( i di.nexti di.prev.next) 
    ! ( i ) \ di.prev.next = di.next
    dup previ ( i di.previ )
    swap nexti ( di.previ di.nexti )
    preva ( d.previ di.next.prev)
    ! ( ) \ di.next.prev = di.previ
    ;

\ insert item j after item at index i (forward links only)
\ i k -> i j k
\ dj.next = di.next (=k)
\ di.next = j

: llf-insert ( i j -- )
    over nexti ( i j di.nexti)
    over nexta ( i j di.nexti dj.next)
    ! ( i j ) \ dj.next = di.nexti
    swap nexta ( j di.next ) 
    ! ( ) \ di.next = j
    ;

\ same as llf-insert, but update backwards links only
\ i k -> i j k
\ dj.prev = i
\ di.next.prev = j
: llb-insert ( i j -- )
    2dup ( i j i j )
    preva ! ( i j) \ dj.prev = i
    swap nexti preva ( j di.next.prev )
    !
    ;

: ll-insert ( i j -- ) 2dup llf-insert llb-insert ;

\ swap positions i j in linked list
\ di = data[i]; dj = data[j] 
\ di.prev.next = j
\ dj.next.prev = i
\ di.next = dj.next
\ dj.next = i
\ dj.prev = di.prev
\ di.prev = j

: ll-swap ( i j -- )
    2dup swap ( i j j i)
    previ nexta ( i j j di.prev.next )
    ! \ (i j) di.prev.next = j  
    2dup ( i j i j)
    nexti preva ( i j i j.next.prev)
    ! \ (i j) dj.next.prev = i
    2dup ( i j i j)
    nexti ( i j i dj.nexti)
    swap nexta ( i j dj.nexti di.next)
    ! \ (i j) \ di.next = dj.nexti
    2dup ( i j i j)
    nexta ( i j i dj.next)
    ! ( i j ) \ dj.next = i
    2dup swap ( i j j i )
    previ swap preva ( i j di.previ dj.prev)
    ! ( i j ) \ dj.prev = di.previ
    2dup swap ( i j j i )
    preva ( i j j di.prev )
    ! ( i j ) \ di.prev = j
    drop drop ;

\ move item at position s to position after item t
: ll-move-to ( s t )
    over ll-remove ( s t ) \ ll-remove(s)
    swap ll-insert \ ll-insert(t, s) 
    ;

\ move entry at position i one to the right
: ll-move-one-right ( i -- )
    dup nexti ( i j=nexti)
    ll-swap
    ;
: ll-move-one-left ( i -- )
    dup previ ( i j=previ )
    swap ll-swap
    ;

: ll-move-nright ( i n -- )
    over swap ( i i n )
    ll-findi-nright ( i j=ll-findi-nright(i,n))
    ll-swap ;

: mix ( -- )
    size 0 do
        i dup val ( i val)
        size mod ( i val%size)
        ll-move-nright
    loop ; 
    
: ls clearstack ll-walkvaluesf .s cr clearstack ;

ll-init
ls
\ 1 ll-remove
\ ls
\ ll-walkvaluesb .s clearstack
\ cr ." val 3 to the right=" 0 3 ll-findi-nright . cr

\ cr ." 0 is at mem idx="  ll-find0 . cr

\ \3 2 ll-move-nright
\ ." swapped twice"
\ ll-walkvaluesf .s clearstack
\ ll-walkvaluesb .s clearstack
\ cr ." idx if we move 3 to the right=" 0 3 ll-findi-nright . cr
\ cr ." 0 is at mem idx="  ll-find0 . cr

