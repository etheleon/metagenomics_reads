#!/usr/bin/env perl

use strict;

#Aim: table row::glo column KO
my %glo=();
my $filenum = 0;
my @col=();
push(@col,'GLO');

#Sets up hash
@ARGV = glob("~/sequencing.output/out/seq.0241/*");
while(<>){ if (!/^readID/) {chomp; my @F=split("\t"); $glo{$F[3]}=()}}

#Creates hash of arrays
@ARGV = glob("~/sequencing.output/out/seq.0241/*");
while ($#ARGV + 1 > 0){ 
    $ARGV[0]=~/\/(K\d+)/;
    push(@col, $1); #Adds the KO name
	foreach (keys %glo) { push(@{$glo{$_}},0) }
	open(INPUT, @ARGV[0]) || die $!;
	while(<INPUT>) {
	    if (!/^readID/){
	    chomp;
	    my @F=split("\t");	
	    @{$glo{$F[3]}}[$filenum]++;
	    }
	}
	close(INPUT);
	$filenum++;
	shift @ARGV; 
}

open(OUTPUT, "> out/seq.0247.out") || die $!; 

print OUTPUT join("\t", @col),"\n";
foreach (keys %glo) {
print OUTPUT "$_\t";
print OUTPUT join("\t", @{$glo{$_}});
print OUTPUT "\n";
}

