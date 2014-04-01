#!/usr/bin/perl -w
#
# Name:   gridwalk.pl
# Author: Simon Morton
#
use strict;
use warnings;
use GD;

# initialize data structures with initial point (0,0) already visited and counted
my @stack   = ([0,0]);
my %visited = (0 => {0 => 1});
my $count   = 1;

my $image = new GD::Image(1024,1024);
my $black = $image->colorAllocate(0,0,0);       
my $green = $image->colorAllocate(0,255,0);
$image->setPixel(512, 512, $green); 

my %sum; # digit sum cache

my $max = (shift or 19);

sub sumDigits($);

sub sumDigits($)
{
  my $number = abs(shift);

  if ( !defined($sum{$number}) ) {

    if ( $number < 10 ) {
      $sum{$number} = $number;

    } else {
      $sum{$number} = $number%10 + sumDigits(int($number/10));
    }
  }
  $sum{$number};
}

sub visitable ($)
{
  my $pos = shift;
  (sumDigits($pos->[0]) + sumDigits($pos->[1])) <= $max;
}

sub visited ($)
{
  my $pos = shift;
  defined($visited{$pos->[0]}) && defined($visited{$pos->[0]}->{$pos->[1]});
}

sub visit ($)
{
  my $pos = shift;
  $visited{$pos->[0]}->{$pos->[1]} = 1;
	$image->setPixel(512+$pos->[0], 512+$pos->[1], $green); 
	$image->setPixel(512+$pos->[0], 512-$pos->[1], $green); 
	$image->setPixel(512-$pos->[0], 512+$pos->[1], $green); 
	$image->setPixel(512-$pos->[0], 512-$pos->[1], $green); 
}

while (@stack) {
  my $old_pos = pop @stack;

  foreach my $move (([0,1],[1,0],[0,-1],[-1,0])) {
    my $pos = [$old_pos->[0]+$move->[0],$old_pos->[1]+$move->[1]];

    # by symmetry we only consider the first quadrant and compensate when counting
    if ( !visited($pos) && visitable($pos) && $pos->[0] >= 0 && $pos->[1] >= 0 ) {
      visit($pos);

      if ( $pos->[0] > 0 && $pos->[1] > 0 ) {
        $count += 4; # count interior squares four times

      } else {
        $count += 2; # count axis squares twice
      }

      push @stack, $pos; # push onto stack to check neighbors
    }
  }
}

print "$count\n";

open (my $fh, ">gridwalk.png") or die "Can't open file";
binmode $fh;
print $fh $image->png;
close $fh;

exit;
