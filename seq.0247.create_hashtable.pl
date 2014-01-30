#!/usr/bin/env perl

use strict;
use Storable;

my %glo=();
my $dirname='/export2/home/uesu/sequencing.output/out/seq.0241';

@ARGV = <$dirname/*>;
while(<>) { my @F=split('\t'); $glo{$F[3]}=(); }

store(\%glo, '/export2/home/uesu/sequencing.output/out/seq.0247/glohash.plda');
