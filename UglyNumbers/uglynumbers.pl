#!/usr/bin/perl -w
# Name:        uglynumbers.pl
# Description: Solution to https://www.codeeval.com/open_challenges/42/
# Author:      Simon Morton
use strict;
use warnings;

sub countUglyNumbers($$$$);

my $count;

sub isUgly($)
{
  my $n = shift;

  foreach ((2,3,5,7)) {
    $n % $_ or return 1;
	}
  0;
}

sub countUglyNumbers($$$$)
{
  my $total   = shift;
  my $op      = shift;
  my $current = shift;
	my $rest    = shift;

  if ( length($rest) == 1 ) {
    $count += isUgly($total+$op*($current*10+$rest));

  } else {
    my $next = substr($rest,0,1);
    $rest = substr($rest,1);

    $current = $current*10+$next;

    countUglyNumbers($total,$op,$current,$rest);

		$total = $total+$op*$current;

    countUglyNumbers($total,1,0,$rest);
    countUglyNumbers($total,-1,0,$rest);
  }
}

my $filename = shift;
open (my $fh, $filename) or die "Can't opem $filename";

while (<$fh>) {
  chomp;
  next unless length;
  $count = 0;
  countUglyNumbers(0,1,0,$_);
  print "$count\n";
}

close $fh;

exit;
