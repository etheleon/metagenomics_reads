#!/usr/bin/env perl

#Objective of this script to sieve the input file (MEGAN output) for reads associated

#--Part1: Read the metabkos into perl
open(METABKOS, "< ./data/top.expressed_metabkos.txt") || die ("no file\n");

while(<METABKOS>){ 
    chomp();
	push(@metabkos, $_);
}
#print @metabkos;
close(METABKOS);

#--Part2: Read and store reads associated with metabkos
open (INPUT,"< $ARGV[0]") || die ("no file\n");

while(<INPUT>) { 
	chomp();
	if(!/^#/){
	    m/(\S+)\s(K\d+)/g;
    	    print '"',"$1",'","',"$2",'"',"\n" if $2 ~~ @metabkos;
    	    }
}
#this file is to be used by another file 101 
