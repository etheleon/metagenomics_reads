#!/usr/bin/env perl

open(OUTPUT, "> out/seq.0109a.out.txt") || die ("no file\n");
open(KOLIST, "< data/top.expressed_metabkos.txt") || die ("no file\n");
system("mkdir out/seq.0109.out");
while(<KOLIST>) { 

chomp();
$masterko = $_;

open(OUTPUT2, "> out/seq.0109.out/".$masterko."_row.txt") || die ("no file\n");
open(METABUC, "< data/metab_uncl.txt") || die ("no file\n");
#K03046  HWI-ST884:57:1:1101:13973:2045#0
$i=0;
while(<METABUC>) { 
		if(/$masterko/){
	    	chomp();
	    	/\S+\s+(\S)/;
	    	$i++;
	    	print OUTPUT2 "$i\t$2\n";
		}}
close(METABUC);
print OUTPUT "$masterko\t$i\n";
}
close(KOLIST);
