#!/usr/bin/env perl 

#-- Initialise
use strict; 
use IO::File; 

my $lower=shift;			#Lower bound KO	
my $upper=shift;			#Upper bound KO 
my $directory='out/seq.0113.v5';	#output directory
unless(-d $directory or mkdir $directory) {die "Unable to create $directory\n";};

#&& Checking
my $checkoutput="$directory".'/checking'.'_'."$lower".'_'."$upper".".txt";
open(CHECK, "> $checkoutput") || die ("Can't open checking.txt: $!");

############################################################
#Loops through each sequencing lane			   #
############################################################

#Two Hashes: %IDKO, %kohash. 
#	1 $IDKO{read}=$ko::links reads to ko	
#	2 $kohash{ko}::stores unique KOs identified within this lane	

#-- Gets name of each sequencing lane
my @meight= `ls data/mRNA.0041.ko/ | grep "^b1"`; chomp @meight; 
foreach my $seqlane (@meight) { 

#-- %IDKO{read}={ko}; KOs within the range

    my %IDKO;
    open(READKO, "./data/mRNA.0041.ko/$seqlane") || die ("Can't open ./data/mRNA.0041.ko/$seqlane: $!");
    while(<READKO>) { 
    	/(\S+)\s(K(\d+))/;
    	if($3 >= $lower && $3 <= $upper) { 
    	    $IDKO{$1} = $2; #$hash{$readID}=$ko
    	}} #print $seqlane," ", scalar keys %IDKO,"\n"; #prints no. of keys in this hash

#-- %kohash{KO}; the KOs 
	my %kohash=();
  	while ( (my $key, my $value) = each %IDKO){unless (exists $kohash{$IDKO{$key}}){ $kohash{$IDKO{$key}}=();}}

##-- Make output directory for each lane
    my $directory2="$directory".'/'.$seqlane; 
    unless(-e $directory2 or mkdir $directory2) {die "Unable to create $directory2\n";} 

    my $m8file1="./mRNA.0020.m8/".$seqlane.".1.m8.bz2"; #b1-0057_s_1.1.m8.bz2	
    my $m8file2="./mRNA.0020.m8/".$seqlane.".2.m8.bz2";

#--Foreach mate 
my %out;
foreach my $m8 ($m8file1, $m8file2) { 
open(IN, "bzcat $m8 |") or die;
while(<IN>)
{
    # NOTE: change this when process 454 data with no /1 or /2 suffix
#    my $read = $1 if m/^(\S+)\/\d\s+gi\|\d+\|ref/; #only refseq entries
   my $read = $1 if m/^(\S+)\/\d\s+gi/; 			#all entries
    my $ko = $IDKO{$read};
    next unless $ko;	#if the read doesnt exist goto next line
    unless($out{$ko})	#if the hash does not exists
    {
        $out{$ko} = IO::File->new(">$directory2/$ko") or die $!;
    }
    $out{$ko}->print($_);
}}

#-- Check if the no. of files outputted corresponds with the no. of keys in %kohash
print CHECK "Lane: $seqlane, No of KOs: ", scalar keys %kohash," Outputted: ", scalar keys %out; 
#Lane: b1-0057_s_1, No of KOs: 346 Outputted: 346

#-- Closing opened files
while ( (my $key, my $value) = each %out){
    delete $kohash{$key};	#remove the keys/ko from kohash which had files opened
	$out{$key}->close;	#closes the opened files
    delete $out{$key};
  	    	}
print CHECK " problematic: ",scalar keys %kohash,"\n" 
#-- FIles which were not outputted
#open(NOTP, "> out/seq.0113.v2/$seqlane"."_$lower".'_'."$upper") || die $!;
#while ( (my $key, my $value) = each %kohash){
#print NOTP $key,"\n";
#}
}
##0-- creates batch execution 
#$count=1; while($count <= 16000) {print 'qsub -V -cwd -b y ./script/seq.0113.v2.seek.reads.with.KO.pl'."$count"; $count=$count+499; print " $count\n"; $count++;}
#
#Checking if the script works #Checks if the no of lines ie reads for K00001 correspond
#comm -13 <(perl -aln -F"\t" -e 'chomp;$F[0]=~m/^(\S+)\/\d$/;print $1' out/seq.0113.v2/b1-0057_s_1/K00001 | sort|uniq) <(grep 'K00001' data/mRNA.0041.ko/b1-0057_s_1|perl -aln -F"\t" -e 'print $F[0]' | sort|uniq)
