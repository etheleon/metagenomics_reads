#!/usr/bin/env perl 

use strict;
use Cwd;
    my $cwd = getcwd;
##############################
#Input
##############################

#perl script/seq.0118.extracting_bindary.matrix.data.pl K04077 data/mRNA.0041.ko data/mRNA.0050.taxon out/seq.0118

my $ko=shift;
my $outdir=shift;
my $xwindow=shift;
#-- Concatenate m8 files && Remove subjects from NR database
#system("perl -ne 'print if /\|ref\|/' out/seq.0113.v5/b1*/$ko > $outdir/$ko.m8");

##--Generates input file 
my $kotemp="$ko"."_tempko";
open(TEMP, "> $outdir/$kotemp") || die "Cannot open $outdir/$kotemp: $!";
print TEMP q(load taxGIFile='/export2/home/uesu/downloads/gi_taxid_prot.bin';
);
print TEMP qq(import blastFile='$cwd/$outdir/$ko.m8' meganFile='$cwd/$outdir/$ko.rma' maxMatches=100 minScore=35.0 maxExpected=1.0 topPercent=10 minSupport=5 minComplexity=0.44 useMinimalCoverageHeuristic=false useSeed=false useCOG=false useKegg=true paired=false useIdentityFilter=false textStoragePolicy=0 blastFormat=BlastTAB mapping='Taxonomy:GI_MAP=true,KEGG:GI_MAP=true';
quit;);
close(TEMP);

###--Run cmd
open(PARTTWO, "> $outdir/$kotemp"."_2") || die "Cannot open $outdir/$kotemp"."_2:$!";
print PARTTWO "qsub -V -cwd -b y \047xvfb-run -a -n $xwindow /export2/home/uesu/megan/MEGAN -g -d -E < $outdir/$kotemp -L /export2/home/uesu/downloads/MEGAN5-academic-license.txt\047";
close(PARTTWO)

