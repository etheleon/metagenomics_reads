#!/usr/bin/env perl

die "usage: seq.0223.get_reads_actual.assignment.pl KXXXXX " unless $#ARGV +1 == 1;

use strict;
use REST::Neo4p;
use REST::Neo4p::Query;

sub uniq {return keys %{{ map { $_ => 1 } @_ }};} #sorts keys 

#Inputs
my $KO=$ARGV[0];
my $inputfile='out/seq.0231/'.$KO.'-full.list.txt';
my $outputfile='out/seq.0241/'.$KO.'-family-GLOS';

#NEO4j SERVER
my $server = 'http://192.168.100.1:7474'; REST::Neo4p->connect($server);
my $stmt='start basetaxa=node:ncbitaxid(taxid={taxids}) match basetaxa-[:childof*]->(genus:`genus`) return genus.taxid';

#Starts reading files
#Example line		
#HWI-ST884:57:1:1101:13687:2939#0/1      357808  63.54   383372  63.54   316274  58.54 
open(OUTPUT, ">","$outputfile") || die $!;
print OUTPUT "readID\tno.of.basetaxa\tno.of.genustaxa\tGLO\n"; 	#Header

open(INPUT, $inputfile) || die $!;
while(<INPUT>){
    chomp;
    my @FF = split("\t",$_);
    my $readid=$FF[0]; 
    shift @FF; 

    my $threshold=$FF[1] * 0.8; #no regardless if this score is given to the top hit or not
    my @basetaxa=();
    my @genustaxa=();
####################################################################################################
    while(scalar @FF > 0) { #Loops through the assignments
	
	if($FF[0] == 0){	#skip if assigned to unknown ie. $FF[0] = 0 
	    shift @FF; shift @FF; 
	}else{
	    if($FF[1] > $threshold){
	  push(@basetaxa, $FF[0]);
	    	shift @FF; shift @FF; 
	    	}else{
	    shift @FF; shift @FF; 
	    }
	}
    }
@basetaxa = uniq(@basetaxa);	#removes duplicates
####################################################################################################

#PRINTING##
print OUTPUT $readid,"\t",$#basetaxa+1,"\t";
###########

foreach my $taxa (@basetaxa) { 
	my $query = REST::Neo4p::Query->new($stmt,{ taxids => $taxa });
	$query->execute;
	while (my $result = $query->fetch) {
	    push @genustaxa, $result->[0];
	}
    }
	@genustaxa = uniq(@genustaxa);

	print OUTPUT $#genustaxa+1,"\t";
    	@genustaxa = sort {$a <=> $b} @genustaxa;
	
	print OUTPUT join("_", @genustaxa),"\n";
}
close INPUT;
close OUTPUT;

