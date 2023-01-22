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

ll-init

