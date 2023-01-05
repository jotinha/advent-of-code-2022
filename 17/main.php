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

function hits_wall($piece) { 
    $wall = 0x1010101; # same as 1 | (1<<8) | (1<<16) | (1<<24); 
    return ($piece & $wall) > 0;
};

function hits_world($piece, &$world, $y) {
    
    for ($i=0; $i < 4; $i++) {
        $row = $piece & 0b1111_1111; # mask last row
        if ((ord($world[$y+$i]) & $row) > 0) return true;
        $piece >>=8; # scroll the piece down one line
    } 
    return false;
}

function place($piece, &$world, $y) {
    for ($i=0; $i < 4; $i++) {
        $row = $piece & 0b1111_1111; # mask last row
        $world[$y+$i] = chr(ord($world[$y+$i]) | $row);
        $piece >>=8; # scroll the piece down one line
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
    
        if (!hits_wall($candidate) and !hits_world($candidate, $world, $y)) { 
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
            if ($y + 4 > strlen($world)) throw new Error("world out of bounds");
            $pieces_iter->next();
            $piece = $pieces_iter->current();

        } #else {echo ":\n";}
        #preview($pieces->current(), $world, $y);
        #if (($n % 1000) == 0)
        #$hh=height_after_complete_line($world,$height);
        #echo "h=$height, toline=$hh\n";
    }
}
function height_after_complete_line(&$world, $y) {
    for ($i = $y; $i >= 0; $i--) {
        #echo $i,":", substr(decbin($world[$i] ?? 0 | 1<<8),1), "\n";
        if (($world[$i] ?? 0) == (0xFF^1)) {echo "<---- ", $y-$i,"\n"; break;}
    }
    return $y-$i;
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
    
#foreach($pieces as $p) {echo "\n";draw($p>>8);}
foreach($pieces as $p) assert(!hits_wall($p));
foreach($pieces as $p) assert(!hits_wall($p << 1));
foreach($pieces as $p) assert(!hits_wall($p << 2));
foreach($pieces as $p) assert(hits_wall($p << 3));
foreach($pieces as $p) assert(!hits_wall($p >> 1));
assert(piece_height($pieces[0])==1);
assert(piece_height($pieces[1])==3);
assert(piece_height($pieces[2])==3);
assert(piece_height($pieces[3])==4);
assert(piece_height($pieces[4])==2);

$world = str_repeat("\0",1<<21); # max is 2GB (1<<31)-1
#$ans1 = simulate($pieces, $world, $moves, 2022);
$ans1 = "TODO";
#$ans2 = simulate($pieces, $world, $moves, 1_000_000_000_000);
$ans2 = simulate($pieces, $world, $moves,  1_000_000);

#display($world);
echo "$ans1,$ans2\n";

#display($world);
