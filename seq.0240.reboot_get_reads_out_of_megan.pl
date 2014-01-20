#!/usr/bin/env perl

use strict;
use Cwd;

my $dir = getcwd;
my @rma=`ls $dir/out/seq.0118/*.rma`;
#print $#rma;
			    foreach my $rmafile (@rma) { 
			    chomp $rmafile;
			    $rmafile=~m/(K\d+)\.rma/g;
			    my $file="open file=\047$rmafile\047; unCollapse nodes=all; select nodes=all; export what=DSV format=readname_matches separator=tab file=\047/export2/home/uesu/sequencing.output/out/seq.0231/$1-full.list.txt\047; quit;\n";
			    system("xvfb-run -a /export2/home/uesu/local/megan/MEGAN -g -d -E <<< \"$file\" -L /export2/home/uesu/downloads/MEGAN5-academic-license.txt");
			    }
