#!/usr/bin/env perl 

open(ROWORD,"< 	data/updated.unique.taxidlist.txt") || die $!;
#open(ROWORD,"< 	temp.taxidlist") || die $!;
while(<ROWORD>) { 
    chomp;
   push(@taxid, $_) 
}
close(ROWORD);

#Some IDs were merged. ie. the ID is not updated and there'll be mapping to the same taxa

#taxid2ranking
open(TAXRANK, "> out/seq.0111.out.txt") || die $!;
print TAXRANK "taxid\tcolnumber\tgenus\n";
open(TAXON, "< data/tax/nodes.dmp") || die $!;
#open(TAXON, "< temp.nodes.dmp") || die $!;
while(<TAXON>){ 
	my @arr=split("\t\|\t",$_);
@index= grep { $taxid[$_] eq $arr[0]} 0..$#taxid;
$size=@index;
#print $size if $size > 1;
if($size > 0){ 
##	if(exists $taxid{$arr[0]}){ #if the taxid exists in the 
foreach(@index){
    $_++;
    print TAXRANK "$arr[0]\t$_\t$arr[4]\n";
#    print "$arr[0]\t$_\t$arr[4]\n";
    	}
}
}
close(TAXON);
close(TAXRANK);
