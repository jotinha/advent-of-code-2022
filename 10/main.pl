use strict;
use warnings;

open my $in,'<','input' or die "Could not open file";

my $cycle = 1;
my $x = 1;
my $strength = 0;

sub step {
    if (($cycle + 20) % 40 == 0) {
       $strength += $cycle*$x 
    }
    $cycle += 1;
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
print "$strength\n"
