#!/usr/bin/env perl 

$directory='out/seq.0220'; unless(-e $directory or mkdir $directory) {die "Unable to create $directory\n";}

#foreach KO, output the 
open(INPUT, $ARGV[0]) || die $!;
while(<INPUT>){ 
chomp;
open(OUTPUT, ">out/seq.0220/$_".".megan.precount") || die $!;
print OUTPUT qq(open file=\047/export2/home/uesu/sequencing.output/out/seq.0118/$_.rma\047;
unCollapse nodes=all;
select nodes=all;
export what=DSV format=taxonid_count separator=tab counts=assigned file=\047/export2/home/uesu/sequencing.output/out/seq.0221/$_.count\047;
quit;
);
close(OUTPUT);
}
close(INPUT);
#create the instructions
#perl -ne 'print "qsub -V -cwd -b y script/seq.0220.generate.counts.pl $_"' data/top500kos.txt | sh
#run the instructions
#ls out/seq.0220/ | perl -ne 'BEGIN{$i=1} chomp; print qq(qsub -V -cwd -b y \047xvfb-run -a -n $i /export2/home/uesu/megan/MEGAN -g -d -E < /export2/home/uesu/sequencing.output/out/seq.0220/$_ -L /export2/home/uesu/downloads/MEGAN5-academic-license.txt\047\n); $i++;' | sh
