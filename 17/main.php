<?php

$data = trim(file_get_contents("input"));
$moves = str_split($data);

$world = [];

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
        if ((($world[$y+$i] ?? 0) & $row) > 0) return true;
        $piece >>=8; # scroll the piece down one line
    } 
    return false;
}

function place($piece, &$world, $y) {
    for ($i=0; $i < 4; $i++) {
        $row = $piece & 0b1111_1111; # mask last row
        $world[$y+$i] = ($world[$y+$i] ?? 0 ) | $row;
        $piece >>=8; # scroll the piece down one line
    }
} 

function simulate_one($piece, &$world, &$moves, $height=0) {
    $y = $height + 3; 
    #echo "spawining new piece\n";
    while($moves->valid() ) { 
        $wind = $moves->current();
        $moves->next();
        
      
        #preview($piece, $world, $y);
       
        $candidate = $wind == '<' ? $piece << 1 : $piece >> 1;
        #echo "y=$y $wind Will hit wall? ";
        if (!hits_wall($candidate) and !hits_world($candidate, $world, $y)) { 
            $piece = $candidate;
            #echo "no\n";
        } #else { echo "yes\n";}
       
         
        #preview($piece, $world, $y);
        
        $y--; 
        #echo "Will hit world? ";
        if ($y < 0 or hits_world($piece, $world, $y)) {
            place($piece, $world, $y+1);
            #echo "yes\n";
            return max($y+1+piece_height($piece), $height);
        } #else { echo "no\n";}
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
    for ($i = max(array_keys($world)); $i >= min(array_keys($world)); --$i) {
        $row = ($world[$i] ?? 0) | (1<<8) | 1;
        $line = strtr(decbin($row),"01",".@");
        $line[0] = '|'; $line[8] = '|';
        echo $line."\n"; 
    }
    if ($i<=0) echo "+-------+\n";

}
function solve(&$pieces, &$world, $moves, $n) {
    $moves_iter = new InfiniteIterator(new ArrayIterator($moves));
    $pieces_iter = new InfiniteIterator(new ArrayIterator($pieces));
    
    $y = 0;
    $i = 0;
    $moves_iter->rewind();
    foreach($pieces_iter as $piece) {
        $y = simulate_one($piece, $world, $moves_iter, $y);
        if (++$i == $n) break;
    }
    return $y;
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
    

$ans1 = solve($pieces, $world, $moves, 2022);
#$ans2 = solve($pieces, $world, $moves, 1_000_000_000_000);
$ans2 = solve($pieces, $world, $moves, 1_000_000);

#display($world);
echo "$ans1,$ans2\n";
$wall = 0x1010101; # same as 1 | (1<<8) | (1<<16) | (1<<24); 
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
