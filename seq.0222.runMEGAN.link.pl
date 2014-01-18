#!/usr/bin/env perl 

use strict;
#qsub -V -cwd -b y 'xvfb-run -a -n 176 /export2/home/uesu/megan/MEGAN -g -d -E < out/seq.0118/K01915-binary_instructions -L /export2/home/uesu/downloads/MEGAN5-academic-license.txt' 
while(<>) { 
    chomp;
my @FF = split("\t",$_);
my $readid = $FF[0];
  shift @FF; 
	while(scalar @FF > 0) { 
#		my $i=scalar @FF; 
		print "$readid\t$FF[0]\t$FF[1]\n"; 
		shift @FF; shift @FF #shift twice
	} 
}
#system("mkdir out/seq.0222")

#ls out/seq.0118/*-family-*-ex.txt | perl -nle '$ori=$_; $_=~/^*+(K\d+\-family\-\d+\-)\S*$/; print qq(perl ./script/seq.0222.runMEGAN.link.pl $ori > out/seq.0222/$1).q(ex2.txt)'
