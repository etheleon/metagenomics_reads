#!/usr/bin/env perl 

use strict;
use DBI;

#1-- determine bitscore threshold: top 0.8*top.bit.score
my @bitscore=();
open(IN, $ARGV[0]) || die $!; 
while(<IN>) { 
    /\|ref\|.+\s+(\S+)$/;			#only refseq entries
	push(@bitscore, $1);
}
@bitscore = sort { $b <=> $a } @bitscore; 	#sorts the array
my $threshold=$bitscore[0] * 0.8;		#threshold 0.8 of the max bitscore

#############################
#gi2taxid::access the db
#############################
my $dbh = DBI->connect(
#    "dbi:SQLite:dbname=/Users/uesu/sqlpleasure/test.db", #local
    "dbi:SQLite:dbname=data/gi2taxid.db","","",  #db file, user, pwd 
{ RaiseError => 1 },) || die $DBI::errstr;

#Binary matrix 
#HWI-ST884:57:1:2304:20795:18132#0/2     gi|257093507|ref|YP_003167148.1|        87.5    32      4       0       2       9

seek IN, 0, 0;		#goback to the top 
my %reads=();
while(<IN>) { 
#if(m/\|ref\|/ && ) {  #only NR references and reads in the top 20 percent are considered 
/^(\


#Filter1
	if($3 >= $threshold) { 
unless (exist $reads{$1}) { 
	$reads{$1}=();
} 
}



#Fetches the taxid associated with that read
$sth = $dbh->prepare("select * from taxid where gi=$2" );
    $sth->execute();
    my ($gi, $taxid) = $sth->fetchrow();
#what would happen if the gi is missing? sound out! #problem

    if(exists $reads{$taxid}){  #if the read belongs to a KO in that range
	$reads{$taxid}++;
    }else{
	$reads{$taxid}=();
    }
    my $sth->finish(); #ready for second 
}
}
}

#foreach my $keys (%reads) { 
#$dbh->disconnect();
