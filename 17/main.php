<?php

$data = trim(file_get_contents("test"));
$moves = str_split($data);

$world = [];

$pieces = [ # start at two units from left wall
    0b00111100,
    0b00010000_00111000_00010000,
    0b00001000_00001000_00111000,
    0b00100000_00100000_00100000_00100000,
    0b00110000_00110000
];

function move_left($piece) { return array_map('blshift', $piece);}
function move_right($piece) { return array_map('brshift', $piece);}

function hits_wall($piece) { 
    $wall = 0x1010101; # same as 1 | (1<<8) | (1<<16) | (1<<24); 
    return ($piece & $wall) > 0;
};

function hits_world($piece, &$world, $y) {
    foreach($piece as $i => $row) {
        if ((($world[$y+$i] ?? 0) & $row) > 0) return true;
    } 
    return false;
}

function place($piece, &$world, $y) {
    foreach($piece as $i => $row) {
        $world[$y+$i] = ($world[$y+$i] ?? 0 ) | $row; 
    }
} 

function simulate_one($piece, &$world, &$moves, $height=0) {
    $y = $height + 3; 
    echo "move: ", $moves->valid() . "," . $moves->current();
    while($moves->valid() ) { 
        $wind = $moves->current();
        $moves->next();

        echo "$wind y=$y ".join(",",array_map('decbin',$piece))."\n";

        $candidate = $wind == '<' ? move_left($piece) : move_right($piece);
        if (!hits_wall($candidate) and !hits_world($candidate, $world, $y)) { 
            $piece = $candidate;
        }
        
        $dworld = array_pad($world,10,0);
        place($piece, $dworld, $y);
        #display($dworld); 
        
        $y--; 
        if ($y < 0 or hits_world($piece, $world, $y)) {
            place($piece, $world, $y+1);
            return max($y+1+count($piece),$height);
        }
        $dworld = array_pad($world,10,0);
        place($piece, $dworld, $y);
        #display($dworld); 
    }
}

function display(&$world) {
    
    for ($i = max(array_keys($world)); $i >= 0; --$i) {
        $row = ($world[$i] ?? 0) | (1<<7);
        $line = strtr(decbin($row),"01",".@");
        $line[0] = '|'; $line[8] = '|';
        echo $line."\n"; 
    }
    echo "+-------+\n";

}
function solve1(&$pieces, &$world, $moves) {
    $moves_iter = new InfiniteIterator(new ArrayIterator($moves));
    $pieces_iter = new InfiniteIterator(new ArrayIterator($pieces));
    
    $y = 0;
    $i = 0;
    $moves_iter->rewind();
    foreach($pieces_iter as $piece) {
        $y = simulate_one($piece, $world, $moves_iter, $y);
        if (++$i == 2022) break;
    }
    return $y;
}
function draw($piece) {
    $full = $piece | (1<<32);
    $line = substr(strtr(decbin($full),"01",".@"),1);
    assert(strlen($line)==32);
    echo chunk_split($line, 8);
}
    

#$ans1 = solve1($pieces, $world, $moves);
#$ans2 = 0;

#display($world);
#echo "$ans1,$ans2\n";
$wall = 0x1010101; # same as 1 | (1<<8) | (1<<16) | (1<<24); 
draw($wall);
foreach($pieces as $p) {echo "\n";draw($p>>8);}
foreach($pieces as $p) assert(!hits_wall($p));
foreach($pieces as $p) assert(!hits_wall($p << 1));
foreach($pieces as $p) assert(!hits_wall($p << 2));
foreach($pieces as $p) assert(hits_wall($p << 3));
foreach($pieces as $p) assert(!hits_wall($p >> 1));

