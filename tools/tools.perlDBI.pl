#!/usr/bin/env perl 

use strict;
use DBI;

my $rank = shift;
#Sieve out those at this belonging to the rank of interest 

#############################
#gi2taxid::access the db
#############################
my $dbh = DBI->connect(
#    "dbi:SQLite:dbname=/Users/uesu/sqlpleasure/test.db", #local
    "dbi:SQLite:dbname=data/gi2taxid.db","","",  #db file, user, pwd 
{ RaiseError => 1 },) || die $DBI::errstr;

#Fetches the taxid associated with that read
$sth = $dbh->prepare("select * from tax2rank where rank=$rank" );
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
