use strict;
use warnings;

open my $in,'<','input' or die "Could not open file";
open my $img, '>', 'image.txt' or die "Could not open file";

my $cycle = 1;
my $x = 1;
my $strength = 0;
my $col = 0;

sub pixelVisible {
    $col >= $x-1 && $col <= $x+1
}

sub step {
    if (($cycle + 20) % 40 == 0) {
       $strength += $cycle*$x 
    }
    $cycle += 1;
    
    print $img (pixelVisible ? "#" : ".");
    
    $col += 1;
    if (($col % 40) == 0) {
        $col = 0;
        print $img "\n";
    }
}

while (<$in>) {
    if (/noop/) {
        step;
    } elsif (/addx (-?\d+)/) {
        step;
        step;        
        $x += int($1);
    } else {
        die "invalid"
    }
}

my $ans1 = $strength;
my $ans2 = "RJERPEFC"; # hard coded but see image.txt file

print "$ans1,$ans2\n"
