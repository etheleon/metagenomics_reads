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

#Starts reading file 
#1st pass get the basetaxa
my %basetaxahash=();
open(INPUT, $inputfile) || die $!;
while(<INPUT>){
    my @FF = split("\t",$_);
   shift @FF;
    my $threshold=$FF[1] * 0.8; #no regardless if this score is given to the top hit or not
    while(scalar @FF > 0) { #Loops through the assignments
	if($FF[0] == 0){	#skip if assigned to unknown ie. $FF[0] = 0 
	    shift @FF; shift @FF; 
	}else{
	    if($FF[1] > $threshold){
	    $basetaxahash{$FF[0]}=();
	    	shift @FF; shift @FF; 
	    	}else{
	    shift @FF; shift @FF; 
	    }
	}
    }
}
close INPUT;
foreach my $basetaxa (keys %basetaxahash) {
	my $query = REST::Neo4p::Query->new($stmt,{ taxids => $basetaxa });
	$query->execute;
	while (my $result = $query->fetch) {
		$basetaxahash{$basetaxa} = $result->[0];
	}
    }

####################################################################################################
#Example line		
#HWI-ST884:57:1:1101:13687:2939#0/1      357808  63.54   383372  63.54   316274  58.54 
####################################################################################################
open(OUTPUT, ">","$outputfile") || die $!;
print OUTPUT "readID\tno.of.basetaxa\tno.of.genustaxa\tGLO\n"; 	#Header
#2nd pass through the file line by line
open(INPUT, $inputfile) || die $!;
while(<INPUT>){
    chomp;
    my @FF = split("\t",$_);
    my $readid=$FF[0]; 
    shift @FF; 

    my $threshold=$FF[1] * 0.8; #no regardless if this score is given to the top hit or not
    my @basetaxa=();		#this will store the base gi matches
    my @genustaxa=();

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
#####################################################################################################

print OUTPUT $readid,"\t",$#basetaxa+1,"\t";
##might have empty entries ie. all match to unknown
foreach my $taxa (@basetaxa) { 
push @genustaxa, $basetaxahash{$taxa};
}
@genustaxa = uniq(@genustaxa);
@genustaxa = sort {$a <=> $b} @genustaxa;
	print OUTPUT $#genustaxa+1,"\t";
	print OUTPUT join("_", @genustaxa),"\n";
	}
close INPUT;
close OUTPUT;
