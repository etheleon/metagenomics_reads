#!/usr/bin/env perl
#to create the rel.tsv file

use strict;
use DBI;

my $dbh = DBI->connect(
#    "dbi:SQLite:dbname=/Users/uesu/sqlpleasure/test.db", #local
    "dbi:SQLite:dbname=data/gi2taxid.db","","",  #db file, user, pwd 
{ RaiseError => 1 },) || die $DBI::errstr;


#the nodes file
#the rel file

taxid parentid

$sth = $dbh->prepare("select * from tax2rank where rank=$rank" ); 
open(INPUT, $ARGV) || die $!; 
while(<INPUT>) {

    @a=split("\t",$_);
    
    my ($taxid, $parentid) = $sth->fetchrow()
