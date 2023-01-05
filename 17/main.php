<?php

$data = trim(file_get_contents("test"));
$moves = str_split($data);

function collapse_masks(&$masks) {
    return array_reduce($masks, function($acc,$x) {
        return $acc | $x;
    });
}

function space_left(&$piece) {
    $mask = collapse_masks($piece['mask']); 
    for($n=1; ($mask << $n) <= (1<<7); $n++) {}
    return $n-1;
}
function collides_with_world(&$piece, &$world, $y) {
    foreach($piece["mask"] as $i => $m) {
        if (($world[$y - $i] & $m) > 0) { return false; }
    }
}

$floor = 0b1111_1111;
$wall =  0b1000_0000;
$world = [];

$pieces = [ # start at two units from left wall (first bit is wall
    # bitmaps are upside down
    [0b000_1111_0],
    
    [0b000_010_00,
     0b000_111_00,
     0b000_010_00],
    
    [0b000_111_00,
     0b000_001_00,
     0b000_001_00],
    
    [0b000_1_0000,
     0b000_1_0000,
     0b000_1_0000,
     0b000_1_0000],
    
    [0b000_11_000,
     0b000_11_000]
];

function row_collides($row, &$world, $y) {
    return (($world[$y] ?? $wall) & $row) > 0;
}

function collides(&$piece, &$world) {
    foreach($piece as $i => $row) {
        if (row_collides($row, $world, $y)) {
            return true; 
        }
    }
    return false;
}

# shift with wrap around
function blshift($b) { return ($b << 1 | $b >> 7) % 256; }
function brshift($b) { return ($b >> 1 | $b << 7) % 256; }
assert(blshift(0b11) == 0b110);
assert(blshift(0b1100_0001) == 0b1000_0011);
assert(brshift(0b11) == 0b1000_0001);
assert(brshift(0b1100_0001) == 0b1110_0000);

function move_left($piece) { return array_map('blshift', $piece);}
function move_right($piece) { return array_map('brshift', $piece);}

function hits_wall($piece) { 
    foreach($piece as $b) { 
        if (($b & 0b1000_0000) > 0) return true;
    }
    return false;
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

$ans1 = solve1($pieces, $world, $moves);
$ans2 = 0;

display($world);
echo "$ans1,$ans2\n";

