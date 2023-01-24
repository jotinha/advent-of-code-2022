\ loads the data file and pushes it to stack, last value pushed is total number of lines
: read-numbers-file ( c-addr -- x1...xn cnt )
    r/o open-file throw ( fid ) 
    0 swap ( cnt=0 fid ) 
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
    drop ( x1...xn cnt fid )
    close-file throw ( x1..xn cnt)
    ;