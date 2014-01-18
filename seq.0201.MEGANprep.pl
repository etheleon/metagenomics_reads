#!/usr/bin/env perl 

use strict; 

my $ko=shift;
my $inputdir=shift;
my $outdir=shift;
my $taxidbin=shift;
die "usage: $0 K00001 path.to.consolidata.m8.files path.to.store.xvfb.input location.of.mapping.file\nRelative paths accepted" unless $inputdir && $ko =~ m/^K\d{5}$/ && $outdir && $taxidbin;
unless(-d $outdir or mkdir $outdir) {die "Unable to create $outdir\n";};

#####################Part:1###
#--Consolidate tabbed Blast input (.m8) into 1 file 
system("perl -ne 'print if m/ref/' $inputdir/b1*/$ko > $outdir/$ko");
##############################

####################Part:2####
#--Generates xvfb-run input to run MEGAN on server NOTE:minscore=35.0 (not default setting)
my $kotemp="$ko".'_tempko';
open(TEMP, "> $outdir/$kotemp") || die "Cannot open $outdir/$kotemp: $!";
print TEMP qq(
load taxGIFile='$taxidbin'; 
import blastFile='$outdir/$ko' meganFile='$outdir/$ko.rma' maxMatches=100 minScore=35.0 maxExpected=1.0 topPercent=10 minSupport=5 minComplexity=0.44 useMinimalCoverageHeuristic=false useSeed=false useCOG=false useKegg=false paired=false useIdentityFilter=false textStoragePolicy=0 blastFormat=BlastTAB mapping='Taxonomy:GI_MAP=true,KEGG:GI_MAP=false'; 
quit;
);
close(TEMP);
##############################
