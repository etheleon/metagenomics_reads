#!/usr/bin/env perl 

die "Usage: seq.0252.familyORnot.pl input output" unless $#ARGV == 1;

use lib "/export2/home/uesu/perl5/lib/perl5";
use strict;
use REST::Neo4p;
use REST::Neo4p::Query;

my $server = 'http://192.168.100.1:7474'; 
REST::Neo4p->connect($server);

open(INPUT, $ARGV[0]) 		|| die $!;
open(OUTPUT, ">$ARGV[1]") 	|| die $!;

#Step 1a: Stores the genera into an %genera=$family
my %genera =();	#storing the genus -> family hash
while(<INPUT>) { my @F=split("\t",$_); my @a=split("_",$F[1]); foreach(@a) { $genera{$_}=() }	}

#Step 1b: Find the family id for that genus
my $stmt='start basetaxa=node:ncbitaxid(taxid={taxids}) optional match basetaxa-[:childof*]->(family:`family`) return family.taxid';
foreach my $genus (keys %genera) { 
	    my $query = REST::Neo4p::Query->new($stmt, {taxids=>$genus}); 
	    $query->execute;	
    	    while(my $family = $query->fetch){
    	    	if($family->[0] eq ''){
    	    	    $genera{$genus} = 'NULL';	#id if that genus doesnt have a family
    	    	}else{
    	    	    $genera{$genus} = $family->[0];	
    	    	}
	    }
}


#Go back to the start
seek INPUT, 0, 0;
while(<INPUT>){ 
    chomp;
    if (/^ko/){print OUTPUT "$_"."\tfamilyLCAable\n"; 	#header
    }else{
	#K00012  120831_146918   2       0
    	my @F = split("\t");
	my @glos=split("_",$F[1]); 		#pushing the glos into the array @glos
	my %flo=();
	foreach(@glos){ 
	$flo{$genera{$_}}=();
	}
	print OUTPUT "$_\t", scalar keys %flo,"\n";
    }
}
