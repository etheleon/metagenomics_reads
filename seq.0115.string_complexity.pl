#!/usr/bin/env perl 

#Preloading: 
#1. making the genus array::binary.strings
#2. loading the hash genus.tree::table

#node	parent.node	rank
#open(NODES,"data/tax/nodes.dmp") || die $!;
#while(<NODES>){
#    chomp; 
#    @a=split("\t\|\t", $_); 
#    push(@gen,$a[0]) if $_=~/genus/;
##    push(@gen,$a[0]) && print $a[0],"\n" if $_=~/genus/;
##key=child, value=parent
#    $tree{$a[0]}=$a[1];
##key=node, value=rank
#    $rank{$a[0]}=$a[2];
#}
#close(NODES);
###GI to taxid conversion
open(GITAX,"gunzip -c /export2/home/uesu/sequencing.output/taxonomy/ftp.ncbi.nlm.nih.gov/pub/taxonomy/gi_taxid_nucl.dmp.gz|") || die $!;
while(<GITAX>){
    chomp;@a=split("\t", $_); 
    $gi{$a[0]}=$a[2];
};
close(GITAX);	#key=gi, value=taxid
#print $a[0],"\t",$a[1],"\n";
print "done\n";

@ARGV=</export2/home/uesu/sequencing.output/out/seq.0113/with.taxid/K00370/*>;
while(<>){
if(!/^KO\t/){ 
#print $_;
chomp;
@a=split("\t", $_);
#print $a[2],"\n";

$taxid=$gi{$a[2]};
print $taxid,"\n";
#moves up taxo tree to get the genus id #
#while($rank{$taxid} ne 'genus'){$taxid=$tree{$taxid};}
##########################################
#$index= grep { $gen[$_] eq $taxid} 0..$#gen;
#print "Index : $index\n";  

#if($taxid ~~ @gen){ 
#$read{$a[1]}[ ]++ if exist $read{$a[1]}
#else{
#my @arr = map { [] } 1..$n;
#$read{$a[1]}=a
}
}
