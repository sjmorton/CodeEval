#!/usr/bin/perl -w
# Name:        prefix.pl
# Description: Solution to https://www.codeeval.com/open_challenges/7/
# Author:      Simon Morton
use strict;
use warnings;

sub evaluate($);
sub evaluate($)
{
  my $node = shift;

  if ( ref($node) ) {
    my $op    = $node->[0];
    my $left  = evaluate($node->[1]);
    my $right = evaluate($node->[2]);

    return eval("$left $op $right");
  }

  $node;
}

sub buildTree($);
sub buildTree($)
{
  my $tokens = shift;
  my $token  = shift @$tokens;

  if ( $token =~ /^[\+\*\/]$/ ) {
    return [ $token, buildTree($tokens), buildTree($tokens) ];
  }

  $token;
}

my $filename = shift;
open (my $fh, $filename) or die "Can't opem $filename";

while (<$fh>) {
  chomp;
  my @tokens = split(/\s+/, $_);
  print evaluate(buildTree(\@tokens))."\n";
}

close $fh;
exit;
