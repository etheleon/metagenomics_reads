#!/usr/bin/env perl 

$ko=$ARGV[0]; 

@files=`ls out/seq.0113.v2_old`;
foreach (@files) {
    chomp;
$outputfile="out/$ko/"."$_"."__$ko";
$path="out/seq.0113.v2_old/$_/$ko";
#print 'input:'."$path"."\n";
#print 'output:'."$outputfile"."\n";
#print "cp $path $outputfile\n";
system("cp $path $outputfile")     ;
}


