#!/usr/bin/env perl 

use strict;
use Cwd;
    my $cwd = getcwd;
#Things to do: 
#Step one separate out the reads UC and C

##############################
#Input
##############################

#perl script/seq.0118.extracting_bindary.matrix.data.pl K04077 Genus data/mRNA.0041.ko data/mRNA.0050.taxon out/seq.0118
my $ko=shift;
my $taxon=shift;
my $mappingdir=shift; #for KO
my $mappingdir1=shift; #for the taxon
my $outdir=shift;

#-- Concatenate m8 files && Remove subjects from NR database
system("perl -ne 'print if /\|ref\|/' out/seq.0113.v5/b1*/$ko > $outdir/$ko.m8");

#--Run MEGAN

##--Generates input file 
my $kotemp="$ko"."_tempko";
open(TEMP, "> $outdir/$kotemp") || die "Cannot open $outdir/$kotemp: $!";
print TEMP q(
load keggGIFile='/export2/home/uesu/downloads/gi2kegg.map';
load taxGIFile='/export2/home/uesu/downloads/gi_taxid_prot.bin';
);
print TEMP qq(
import blastFile='$cwd/$outdir/$ko.m8' meganFile='$cwd/$outdir/$ko.rma' maxMatches=100 minScore=50.0 maxExpected=1.0 topPercent=10 minSupport=5 minComplexity=0.44 useMinimalCoverageHeuristic=false useSeed=false useCOG=false useKegg=true paired=false useIdentityFilter=false textStoragePolicy=0 blastFormat=BlastTAB mapping='Taxonomy:GI_MAP=true,KEGG:GI_MAP=true';
export what=matchPatterns taxon=2 rank=Genus file='$cwd/$outdir/$ko-ex.txt';
quit;
);

close(TEMP);
#
###--Run cmd
system("xvfb-run -a /export2/home/uesu/megan/MEGAN +g -d -E < $outdir/$kotemp -L /export2/home/uesu/downloads/MEGAN5-academic-license.txt  > /dev/null 2>&1");
#
###--Remove input file
system("rm $outdir/$kotemp");


my @files=<"$mappingdir/b1*">;

##Genus reads which have been assigned to this KO
my %classifiable=(); 
foreach my $file (@files){
    open (IN, $file) || die $!; 
	while(<IN>) { 
	    if(/^(\S+)\s+$ko$/) { 
	$classifiable{$1}=() ;
	    }
	}
close(IN);
}

my @files2=<"$mappingdir1/b1*">;
my %tax=(); 
foreach my $file (@files2){
    open (IN, $file) || die $!; 
	while(<IN>) { 
	/^(\S+)\s+$taxon/;
	if(exists $classifiable{$1}) {$tax{$1}=();}
	}
close(IN);
}

print "total no. of $ko reads: ", scalar keys %classifiable, "\n";
print "total no. of mate pair 1 & 2 reads classifiable to the $taxon rank: ", scalar keys %tax, "\n";


open (BINARYOUT, "> $outdir/$ko-ex2.txt") || die $!;

#-- prints the column names of the binary to the file first
my $colinput ="$outdir".'/'."$ko".'-ex.txt';
my $taxonnames=`head -n 4 $colinput | tail -n 1`;
my @taxonss=split(/\t/,$taxonnames);
shift @taxonss;
$,='	';
print BINARYOUT @taxonss;

open(BINARY, "$outdir/$ko".'-ex.txt') || die $!;
#read	taxa	classification.status
#separated file? header? for the headings? 
my $cl=0; 
my $ucl=0; 

while (<BINARY>) { 
chomp;
    if(/^(\S+)\/\d\s\d+/){
    	if(exists $tax{$1}) {
	    print BINARYOUT "$_\tclassifiable\n"; 
	    $cl++; 
	}else{
    	    print BINARYOUT "$_\tunclassifiable\n";
    	    $ucl++;
    	}	
}}

close(BINARY); 
close(BINARYOUT);

print "$cl reads; $ucl reads\n";

my $totalrows=$ucl+$cl;	#row
my $totalcol=scalar @taxonss;#cols

open (ENDOUT, "> $outdir/$ko".'-summary.txt') || die $!;
print ENDOUT "$totalrows\t$totalcol\n"; 	#the size of the matrix
close (ENDOUT);
