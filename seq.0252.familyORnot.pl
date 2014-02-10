#!/usr/bin/env perl 

use strict;
use REST::Neo4p;
use REST::Neo4p::Query;

my $server = 'http://192.168.100.1:7474'; 
REST::Neo4p->connect($server);

open(INPUT, $ARGV[0]) || die $!;
open(OUTPUT, ">$ARGV[1]") || die $!;

my $stmt='start basetaxa=node:ncbitaxid(taxid={taxids}) match basetaxa-[:childof*]->(family:`family`) return family.taxid';
while(<INPUT>) { 
    	chomp;
    	if ($. == 1){
	    print OUTPUT "$_"."\tfamily\n"
	}else{
    	print OUTPUT $_;
    	my @F = split("\t");
	#K00012  120831_146918   2       0
	my @glos=split("_",$F[1]); 		#pushing the glos into the array @glos
my %fam=();
	foreach my $basetaxa (@glos){		#for each of the genera find the family
	my $query = REST::Neo4p::Query->new($stmt, {taxids=>$basetaxa}); 
	$query->execute;	
						#add the family taxid to the hash %fam
    	while(my $result = $query->fetch){
    	    my $family=$result->[0];	
    	    $fam{$family}=();
	}
	    }
	    my $i=0;
	    foreach(keys %fam){
#	    	print "$_\t";
	    	$i++;
	    }
	    print OUTPUT "\t$i\n";
}
}
