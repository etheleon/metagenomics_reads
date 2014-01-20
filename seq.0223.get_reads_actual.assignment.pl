#!/usr/bin/env perl

use strict;
use REST::Neo4p;
use REST::Neo4p::Query;

if ($#ARGV +1 != 1 ) {
	print "usage: seq.0223.get_reads_actual.assignment.pl KXXXXX ";
	exit;
}

#to remove redundant elements in an array
sub uniq {
    return keys %{{ map { $_ => 1 } @_ }};
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
	open(INPUT, $inputfile) || die $!;
    	while(<INPUT>) { 
    	    chomp;
    	    my @line=split("\t", $_);	#read::$line[0]		taxid::$line[1]		bitscore::$line[2]
    	    	unless($line[1]==0){	#skips lines matching to unknown
####################################################################################################

    		    if(!exists $readid{$line[0]}){ 		#then it has to be a new read, hence it has to be a the max bitscore, cause i skipped all the zeros
			    my @array=();
	    	    	    $readid{$line[0]}=\@array;			#adds read to the the hash
	    	    	    $threshold = $line[2] * 0.8;	#threshold will be the top 20% of bitscore matches
		    	    push @{$readid{$line[0]}}, $line[1];	#NOTE need to add taxid to the hash value (ie. array)
	    	    }else{
			if($line[2] > $threshold){	    	    
		    	    push(@{$readid{$line[0]}}, $line[1]);	#NOTE need to add taxid to the hash value (ie. array)
	    		}
    	    	    }

#Sends query to neo4j server and returns a list of genus for this read
####################################################################################################
    		}
	}
    	    close(INPUT);
#For each base taxid stored in the value array assigned to each read hash key get the genus rank
my $stmt='start basetaxa=node:ncbitaxid(taxid={taxids}) match basetaxa-[:childof*]->(genus:`genus`) return genus.taxid';

print "no.of.reads\tfamily.taxid\treadid\tno.of.uniq.genus\tGLO\n";
#Step1: For each read
foreach my $read (keys %readid) { 
print scalar keys %readid,"\t";
    my @genustaxid=();
    print qq($node\t$read\t);
    my @baseta = @{$readid{$read}};
    @baseta = uniq(@baseta);	#removes duplicates
#Step2: For each basetaxa stored associated with the read
    foreach my $basetaxa (@baseta){#    	print qq($basetaxa).q(|);
	my $query = REST::Neo4p::Query->new($stmt,{ taxids => $basetaxa });
	$query->execute;
	while (my $result = $query->fetch) {
#print $result->[0];
	    push @genustaxid, $result->[0];
	}
    }
print qq(\t);
	@genustaxid = uniq(@genustaxid);
	print $#genustaxid+1,"\t";
    	@genustaxid = sort {$a <=> $b} @genustaxid;
	print join("_", @genustaxid),"\n";
	}
}
