#!/usr/bin/env perl
#This file just outputs selected ko's reads
@kos=("K04077","K03386","K01991","K06076","K00370","K10946","K10535");	#
#@kos=("K04077");

open(OUTPUT, ">read2ko.txt");
foreach $koin (@kos){
#print $koin;
#-- Foreach run store read-ko link and print accompanying reads from m8 file
@readko=`ls data/mRNA.0041.ko/`;

#-- Loops through each runs
foreach $ele (@readko) { 
    $ele=~s/\n//g; #removes the link
#    $ele = $readko[0];
	@reads=();	#clear array; ie. the reads in this array only belong to the run

########################################	
#storing read-ko
########################################	
	$path1='./data/mRNA.0041.ko/'.$ele;
    open(FILE1, "$path1") || die ("no file 1\n");
    while(<FILE1>) {
    	push(@reads,$1) if m/^(\S+)\s+$koin/;
    }
########################################	
    close(FILE1);
    print OUTPUT "$koin\t";
    print OUTPUT join("\n$koin\t",@reads);
}}
close(OUTPUT);
