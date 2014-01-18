#!/usr/bin/env perl 

#Col: the taxaID
open(TAXID2, "<data/unique.taxidlist.txt") || die ("no file\n"); 
	$i=1;
	while(<TAXID2>)	{ 
    	    chomp();
    	    #KEY:taxid; VALUE:colnumber
    	    $taxid{$_}=$i;
    	    $i++;
    	    		} 
close(TAXID2); 
########################################################################

##-- Part2:building mapping file gi2taxid ############################## 
open(TAXID, "< data/gi2taxid.refseq") || die ("no file\n"); #12 million entries
while(<TAXID>) {
    chomp();
#   gi|4501845      9606 
    m/gi\|(\d+)\s(\d+)/;
    $checklist{$1}=$2;
    #key:gino 	value:taxid
}
close(TAXID);
########################################################################

#For each of the top expressed KOs
open(KOLIST, "< data/top.expressed_metabkos.txt") || die ("no file\n");
#open(KOLIST, "< data/top.expressed_metabkos_testing.txt") || die ("no file\n");
while(<KOLIST>) { 
	    chomp();
	    $masterko = $_;
    	    %counting = ();	 #Clear the hash everytime the it switches to a new KO

$filenam=$ARGV[0];
$filenam=~s/^\S+\/(\S+)$/$1/g;
$outputdir= join "", q(out/seq.0107/),$masterko;
system("mkdir $outputdir");
$outputloc='./out/seq.0107/'.$masterko.'/'.$filenam.'.output';
open(OUTPUT, "> $outputloc") || die ("noo file\n");

#Row: Read the reads specific to that KO interrogated 
open(METABUC, "< data/metab_uncl.txt") || die ("no file\n");
#K03046  HWI-ST884:57:1:1101:13973:2045#0
	$i=1;	
	while(<METABUC>) { 
		if(/$masterko/){
    	    	chomp();
	    	#KEY:ko__read; VALUE:rownumber
	    	m/\S+\s+(\S+)/;
		$counting{$1}=$i;	#gives a counter to the read
		$i++;
		}}
close(METABUC);

open(RAPSEARCH, "bzcat $ARGV[0] |") || die ("no file\n");
#open(RAPSEARCH, "$ARGV[0]") || die ("no file\n");
	while(<RAPSEARCH>){ 
	if(!/^\#/ && m/\|ref\|/) { 	#ignores the intro few lines and only considers reads from ref
	    m/^(\S+)\/\d\tgi\|(\d+)/;	#$1: is the readID, $2 is giID
		if(exists $counting{$1}){ #ie. the read belongs to the KO in question
		#find which array row number ko 
		$row=$counting{$1};
		#find which taxid 
		$col=$taxid{$checklist{$2}};
		print OUTPUT "$row\t$col\n";
				}
	}}
close(RAPSEARCH);	
close(OUTPUT);
}
close(KOLIST);
#ls mRNA.0020.m8/ | perl -ne 'print q(qsub -V -cwd -b y perl script/seq.0107.sieve.reboot.pl mRNA.0020.m8/).$_' > script/seq.0108.feedperl.sh
