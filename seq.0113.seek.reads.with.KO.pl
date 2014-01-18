#!/usr/bin/env perl

#KO of interest
#high.uncl.low.cl
#K04077 (high counts:29--no.of.classified genus:121)
#K03386 (med counts:30--no.of.classified genus:71)

#medmed
#K01991
#K06076

#low.uncl.high.cl
#K00370
#K10946
#K10535
#

#Plan: 
#
#for each of the KOs listed above, { 		
#			take in the reads associated with KO;
#			loop through list of associated reads output each run
#						} 

#@kos=("K04077","K03386","K01991","K06076","K00370","K10946","K10535");	
#@kos=("K04077");
#

##############################
#PART1: stores reads associated with KO
##############################
$koin = $ARGV[0]; 			#KO given in arguement
#foreach $koin (@kos){ 			#Short list

#-- Foreach sequencing run ($ele) store readID into array @readko
@readko=`ls data/mRNA.0041.ko | grep "^b1" `;
    foreach $ele (@readko) { 
    	$ele=~s/\n//g; 	#housekeeping
	@reads=();	#initialise array; ie. the reads in this array only belong to the run
##############################

########################################	
#--Storing readID for the KO of interest
########################################	
$path1='./data/mRNA.0041.ko/'.$ele;
open(FILE1, "$path1") || die ("no file 1\n");
while(<FILE1>) {
    push(@reads,$1) if m/^(\S+)\s+$koin/;
}
########################################	

@readshash{@reads}=(); #initialise hash of where key = @read
#my @array_I_just_created_here = (a .. z);
#my @hash_I_just_created_here{@array_I_just_created_here} = ();
#print "yes, c is a letter that would exist within that array you just created there.$/" if exists $hash_I_just_created_here{"c"};

########################################
#Step2: open the m8 files and search & prints reads 
########################################
open(OUTPUT, 	"> out/seq.0113/"."$koin"."_"."$ele".".txt")|| die ("cannot output\n");
#-- Header
#print OUTPUT "KO\tREAD\tGI\tbitscore\n";
	#mate1
	$run1="./mRNA.0020.m8/".$ele.".1.m8.bz2";
	open(FILE2, "bzcat $run1 |") || die ("no file $run1\n");
	while(<FILE2>) {
    	    if(!/^\#/ && m/\|ref\|/) {      #ignore
#		m/^(\S+)\/\d\tgi\|(\d+).+\s(\S+)$/;   #read and gi
#	    	    print OUTPUT "$koin\t$1\t$2\t$3\n" if exists $readshash{$1};
		m/^(\S+)\/\d\tgi/;   #read and gi
		print OUTPUT if exists $readshash{$1};
    	    }}
#	print "matepair1 done\n";

	#reads2
	$run2="./mRNA.0020.m8/".$ele.".2.m8.bz2";
	open(FILE3, "bzcat $run2 |") || die ("no file $run2\n");
	while(<FILE3>) {
    	    if(!/^\#/ && m/\|ref\|/) {      #ignore
#		m/^(\S+)\/\d\tgi\|(\d+).+\s(\S+)$/;   #read and gi
#	    	    print OUTPUT "$koin\t$1\t$2\t$3\n" if exists $readshash{$1};
	    	m/^(\S+)\/\d\tgi/;   #read and gi
		print OUTPUT if exists $readshash{$1};
    	    }}
#	print "matepair2 done\n";
#	print "Part2 done\n";
	}
#}
