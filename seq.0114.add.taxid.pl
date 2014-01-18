#!/usr/bin/env perl 

#The magic code
#perl -pe 'BEGIN{open(T,"data/gi2taxid.refseq"); while(<T>){chomp; $checklist{$1}=$2 if m/gi\|(\d+)\s(\d+)$/g}} m/^K\d+\s\S+\s+(\S+)/; $taxid=$1; $_=~s/(\S+)$/$1\t$checklist{$taxid}/' 

open(T1, "data/gi2taxid.refseq") || die ("sian\n");
while(<T1>){
    chomp; $checklist{$1}=$2 if m/gi\|(\d+)\s(\d+)$/g;
}
close(T1);

open(T2, $ARGV[0])|| die ("sian2\n");
#with tax id

open(T3, ">",join("", $ARGV[0],".with.taxid"))|| die ("sian22\n");
while(<T2>) { 
    m/^K\d+\s\S+\s+(\S+)/; 
    $taxid=$1; 
    s/(\S+)$/$1\t$checklist{$taxid}/;
    print T3 $_;
}
close(T3);
close(T2);
#When you run this, you should just have that line above in this file and the output will be in idk.testing
#perl -e 'BEGIN{@a=`ls out/seq.0113`;} foreach $e (@a){print "qsub -V -cwd -b y ","script/seq.0114.add.taxid.pl"," $e"}' > idk.testing
