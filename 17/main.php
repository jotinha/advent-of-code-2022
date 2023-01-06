<?php

$data = trim(file_get_contents("input"));
$moves = str_split($data);

$pieces = [ # start at two units from left wall
    0b00111100,
    0b00010000_00111000_00010000,
    0b00001000_00001000_00111000,
    0b00100000_00100000_00100000_00100000,
    0b00110000_00110000
];

function make_world($size) {
    #world is a stream of bytes, each byte is a row with 8 bits, the first 7 are
    #set to zero (nothing) and the rightmost is set to 1 (wall). No need for the left
    #wall because moving a piece left wraps it around to the right
    return str_repeat("\1",$size);
}

function hits_world($piece, &$world, $y) {
    return ($piece & getframe($world, $y)) > 0;
}

function getframe(&$world, $y) {
    return unpack("L",substr($world, $y, 4))[1];
}

function place($piece, &$world, $y) {
    $frame = $piece | getframe($world,$y);
    $s = pack("L",$frame);
    for ($i=0; $i < 4; $i++) {
        $world[$y+$i] = $s[$i]; 
    }
} 

function simulate(&$pieces, &$world, $moves, $n) {
    $moves_iter = new InfiniteIterator(new ArrayIterator($moves));
    $pieces_iter = new InfiniteIterator(new ArrayIterator($pieces));
   
    $height = 0;
    $y = $height + 3;

    $pieces_iter->rewind();   
    $piece = $pieces_iter->current();
    #echo "rock begins falling\n";
    #preview($piece, $world, $y); 

    foreach($moves_iter as $wind) {
        #echo count($world)."\n";
       
        $candidate = $wind == '<' ? $piece << 1 : $piece >> 1;
        #echo "Jet of gas pushes rock $wind";
    
        if (!hits_world($candidate, $world, $y)) { 
            $piece = $candidate;
            #echo "\n";
        } #else { echo "but nothing happens\n";}
         
        #preview($piece, $world, $y);
        
        $y--; 
        #echo "Rock falls 1 unit";
        if ($y < 0 or hits_world($piece, $world, $y)) {
            place($piece, $world, $y+1);
            #echo "causing it to come to rest\n";
            $height = max($y+1+piece_height($piece), $height);
            $y = $height + 3;
            #if ($n % 10_000 == 0) echo "$n\n";
            if (--$n == 0) return $height;
            
            #echo "A new rock begins falling\n";
            if ($y + 4 >= strlen($world)) throw new Error("world out of bounds");
            $pieces_iter->next();
            $piece = $pieces_iter->current();

        } #else {echo ":\n";}
        #preview($pieces->current(), $world, $y);
        #if (($n % 1000) == 0)
        #$hh=height_after_complete_line($world,$height);
        #echo "h=$height, toline=$hh\n";
    }
}

function piece_height($piece) {
    $i = 0;
    while (($piece & 0xFF) > 0) {
        $i++;
        $piece >>= 8;
    }
    return $i;
}

function display(&$world) {
    
    for ($i = strlen($world)-1; $i >= 0; --$i) {
        $row = ord($world[$i]) | (1<<8) | 1;
        $line = strtr(decbin($row),"01",".@");
        $line[0] = '|'; $line[8] = '|';
        echo $line."\n"; 
    }
    if ($i<=0) echo "+-------+\n";

}
function draw($piece) {
    $full = $piece | (1<<32);
    $line = substr(strtr(decbin($full),"01",".@"),1);
    assert(strlen($line)==32);
    echo chunk_split($line, 8);
}
function preview($piece,&$world, $y) {
    $world2 = [];
    for ($i=$y+5;$i>$y-5 and $i>=0;$i--) {
        $world2[$i] = $world[$i] ?? 0;
    }
    place($piece, $world2, $y);
    display($world2); 
}
    
$world = make_world(1<<17);
$ans1 = simulate($pieces, $world, $moves, 2022);

$world = make_world(1<<25);
$ans2 = simulate($pieces, $world, $moves, 100_000);

echo "$ans1,$ans2\n";
