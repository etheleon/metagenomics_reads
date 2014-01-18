#!/usr/bin/env perl 

#-- Part 1: Build array of arrays #####################################
	#Rows
open(KOLIST, "< data/top.expressed_metabkos.txt") || die ("no file\n");
	$i=0;
	while(<KOLIST>) { 
    	    chomp();
    	    $counting{$_} =$i;
    	    #the value to point to the location of KO in matrix: column  
	$i++;
	}
close(KOLIST);
$i=$i-1;
	#Columns
open(TAXID2, "<data/unique.taxidlist.txt") || die ("no file\n");
	$io=0;
	while(<TAXID2>){ 
	chomp();	
	$taxid{$_} = $io;
	$io++;
	}
close(TAXID2);

@koarray = (0) x $i;
for my $ele(0 .. $i) { 
	@taxid = (0) x $io;
	$koarray[$ele] = [@taxid];
}
#####################################################################

#-- Part2:building mapping file gi2taxid ############################## 
open(TAXID, "< data/gi2taxid.refseq") || die ("no file\n"); #12 million entries
while(<TAXID>) {
    chomp();
    m/gi\|(\d+)\s(\d+)/;
    $checklist{$1}=$2;
    #key:gino 	value:taxid
}
close(TAXID);
######################################################################

#-- Part3:building mapping file read2ko ##############################
open(METABUC, "< data/metab_uncl.txt") || die ("no file\n");
								#open(METABUC, "< metab_uncl_test") || die ("no file\n");
while(<METABUC>){ 
    	chomp(); 
	m/(\S+)\s(\S+)/;
	$koread{$2} = $1;
}	
close(METABUC);
######################################################################

open(RAPSEARCH, "bzcat $ARGV[0] |") || die ("no file\n");	#Foreach read open the 
	while(<RAPSEARCH>){ 
	if(!/^\#/ && m/\|ref\|/) { 	#ignores the intro few lines and only considers reads from ref
	    m/^(\S+)\/\d\tgi\|(\d+)/;	
		if(exists $koread{$1}){ 
		$ko=$koread{$1};
		#find which array row number ko 
		$row=$counting{$ko};
		#find which taxid 
		$col=$taxid{$checklist{$2}};
		$koarray[$row][$col]++;
				}
	}}
close(RAPSEARCH);	

#-- Part 4 output file##############################
$filenam=$ARGV[0];
$filenam=~s/^\S+\/(\S+)$/$1/g;
$outputloc='./out/seq.0104/'.$filenam.'.output';
open(OUTPUT, "> $outputloc") || die ("noo file\n");
for $aref ( @koarray ) {
        print OUTPUT "@$aref\n";
    }
close(OUTPUT);

##ls mRNA.0020.m8/ | perl -ne 'print q(qsub -V -cwd -b y perl script/seq.0103.sieve.pl mRNA.0020.m8/).$_' > script/seq.0104.feedperl.sh
