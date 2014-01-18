#!/usr/bin/env perl

use strict;
use REST::Neo4p;
use REST::Neo4p::Query;

if ($#ARGV +1 != 1 ) {
	print "usage: seq.0223.get_reads_actual.assignment.pl KXXXXX ";
	exit;
}

#Database     	
my $server = 'http://192.168.100.1:7474';
REST::Neo4p->connect($server);
my $stmt = 'start base=node:ncbitaxid(taxid={param}) match base-[:childof*]->(genus:`genus`) return genus.taxid';

my $KO=$ARGV[0];
my $outputfile='out/seq.0223/'.$KO.'-family-GLOS';

#Gets family taxids for this KO 
my $command=q(ls out/seq.0222/).$KO.q(-family-*).q(|perl -ne '/\-(\d+)/; print qq($1\t)');
my $execute=`$command`;
my @familytaxids=split("\t",$execute);

foreach my $node (@familytaxids) #for each family node
{
    	my $inputfile='out/seq.0222/'.$KO.'-family-'.$node.'-ex2.txt'; 
    	my %readid=(); #reinitialises the hash which will store unique readIDs

###################################################
#Basically store all the taxids for that read into a hash parse it to REST::neo4p
####################################################

#Read through the file and get all the base taxids and use the REST package to call out all the genus and store it into a hash (Question will this be viable? ie will the has mutate into something huge?)

    	my $threshold=0;
    	my @qualifyingtaxa = ();	
	
	open(INPUT, $inputfile) || die $!;
    	while(<INPUT>) { 
    	    chomp;
	    @qualifyingtaxa=();			#reinitialises hash storing &
    	    my @line=split("\t", $_);	#read::$line[0]		taxid::$line[1]		bitscore::$line[2]
    	    	unless($line[1]==0){	#skips lines matching to unknown
####################################################################################################

    		    if(!exists $readid{$line[0]}){ 		#then it has to be a new read, hence it has to be a the max bitscore, cause i skipped all the zeros
	    	    	$readid{$line[0]}={};			#adds new key
	    	    	    $threshold = $line[2] * 0.8;	#threshold will be the top 20% of bitscore matches
		    	    push(@qualifyingtaxa, $line[1]);	#pushes the taxid into @qualifyingtaxa
#	    	    	print OUTPUT "$_\t$threshold\n";	
	    	    }else{
			if($line[2] > $threshold){	    	    
#    			print OUTPUT "$_\t$threshold\n" 
    			    push(@qualifyingtaxa, $line[1]);
	    		}
    	    	    }
#the array here stores a whole bunch of taxids
foreach my $taxaa (@qualifyingtaxa){
my $query = REST::Neo4p::Query->new($stmt,{ param=>$taxaa });
$query->execute;

while (my $result = $query->fetch) {
print $result->[0],"\n";
}
}



#print "\n";
#Sends query to neo4j server and returns a list of genus for this read
#my $query='start basetaxa=node:taxID(taxid={taxids}) match basetaxa-[:childof*]-(genus:`genus`) return genus';
#my $param=@qualifyingtaxa;
####################################################################################################
    		}
	}
    	    close(INPUT);
}
#part 2 need to query neo4j and get the 
