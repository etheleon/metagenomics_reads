#!/usr/bin/env perl

use strict;

my $license=shift;
my $KOlist=shift;

my @KOLIST=();
open(KOLISTFH, $KOlist) || die $!;
while(<KOLISTFH>) {chomp;push(@KOLIST, $_)}
close(KOLISTFH);
#SuperKingdom Kingdom Phylum Class Order Family Varietas Genus Species_group Species Subspecies
my $i=1;
foreach (@KOLIST){ 
print "qsub -V -cwd -b y 'xvfb-run -n $i  /export2/home/uesu/local/megan/MEGAN -g -d -E < out/seq.0118/$_"."_tempko -L $license'\n";
$i++;
}

#sh <(perl script/seq.0202.batchMEGAN.pl ../downloads/MEGAN5-academic-license.txt Phylum ../seq2/data/samplekos
