#!/usr/bin/perl -w
# Name:        levenstein.pl
# Description: Compute size of a word's "social network" based on Levenshtein Distance
# Author:      Simon Morton
use strict;

sub addToDict($$$);
sub findExactMatch($$$);
sub findFriends($$$);

sub addToDict($$$)
{
  my $dict = shift;
  my $word = shift;
  my $rest = shift;

  if ( length($rest) == 1 ) {
    $dict->{$rest}->{word} = $word

  } else {
    my $next = substr($rest,0,1);
    if ( !defined($dict->{$next}) ) {
      $dict->{$next} = {};
    }
    addToDict($dict->{$next},$word,substr($rest,1));
  }
}

sub enqueue($$)
{
  my $queue = shift;
  my $word  = shift;

  unshift(@$queue, $word);
}

sub dequeue($)
{
  my $queue = shift;

  shift(@$queue);
}

sub findExactMatch($$$)
{
  my $dict  = shift;
  my $queue = shift;
  my $word  = shift;

  if ( length($word) == 1 ) {
    if ( defined($dict->{$word}) &&
         defined($dict->{$word}->{word}) ) {
      enqueue($queue,$dict->{$word}->{word});
    }

  } else {
    my $first = substr($word,0,1);
    my $rest  = substr($word,1);
    
    if ( defined($dict->{$first}) ) {
      findExactMatch($dict->{$first},$queue,$rest);
    }
  }
}

sub findFriends($$$)
{
  my $dict  = shift;
  my $queue = shift;
  my $word  = shift;

  if ( length($word) == 1 ) {
    # down to the last letter

    if ( defined($dict->{$word}) ) {
      # one letter added at the end
      foreach (grep { length == 1 } keys %{$dict->{$word}}) {
        if ( defined($dict->{$word}->{$_}) &&
             defined($dict->{$word}->{$_}->{word}) ) {
          enqueue($queue, $dict->{$word}->{$_}->{word});
        }
      }
    }

    foreach (grep { length == 1 } keys %{$dict}) {
      # last letter different
      if ( defined($dict->{$_}->{word}) ) {
        enqueue($queue, $dict->{$_}->{word});
      }
      # another letter inserted before last letter
      if ( defined($dict->{$_}->{$word}) &&
           defined($dict->{$_}->{$word}->{word}) ) {
        enqueue($queue, $dict->{$_}->{$word}->{word});
      }
    }

    if ( defined($dict->{word}) ) {
      # one letter shorter
      enqueue($queue, $dict->{word});
    }

  } else {
    my $first = substr($word,0,1);
    my $rest  = substr($word,1);

    if ( defined($dict->{$first}) ) {
      # we have an exact match so far; check for differences further on
      findFriends($dict->{$first},$queue,$rest);
    }

    # check for a dropped letter
    findExactMatch($dict,$queue,$rest);

    # check for a switched or added letter
    foreach (grep { length == 1 } keys %{$dict}) {
      findExactMatch($dict->{$_},$queue,$word); # added
      findExactMatch($dict->{$_},$queue,$rest); # switched
    }
  }
}

my @inputs;    # list of input words
my $dict = {}; # tree-based dictionary to contain the word list

my $input_file = shift or die "Usage: $0 <input file>\n";

open (my $fh, $input_file) or die "Error: can't open $input_file\n";

while (<$fh>) {
  chomp;
  last if /^END OF INPUT$/;
  next unless /^\s*([^\s]+)\s*$/;
  push @inputs, $1;
}

while (<$fh>) {
  chomp;
  next unless /^\s*([^\s]+)\s*$/;
  addToDict($dict,$1,$1); 
}

close $fh;

foreach (@inputs) {
  my $queue   = [$_]; # queue of words to be checked for friends
  my $network = {};   # hash to contain all words in the network

  while ( my $word = dequeue($queue) ) {
    if ( !defined($network->{$word}) ) {
      $network->{$word} = 1;
      findFriends($dict, $queue, $word);
    }
  }

  print scalar(keys %$network)."\n";
}

exit;
