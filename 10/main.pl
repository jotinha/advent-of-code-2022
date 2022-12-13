use strict;
use warnings;

open my $in,'<','input' or die "Could not open file";

my $cycle = 1;
my $signal = 1;
my $strength = 0;
my $jump = 0;
my $delta = 0;

while (<$in>) {
    
    if (/noop/) {
        $jump = 1;
        $delta = 0;
    } elsif (/addx (-?\d+)/) {
        $jump = 2;
        $delta = int($1);
    } else {
        die "invalid"
    }
 
    my $rest = ($cycle + 20 + 1) % 40;
    if ($rest == 1) { # 20, 40, 80...
        $strength += $cycle*$signal;
        #print "[$strength] ";
    } elsif ($rest == 0 && $jump>1) { # 19, 39, 79...
        $strength += ($cycle+1)*$signal;
        #print "[$strength] ";
    }

    #print "$cycle: ($signal) $_";

    $cycle += $jump;
    $signal += $delta;
}
print $strength
