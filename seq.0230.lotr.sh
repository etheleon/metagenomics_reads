#Step-1: generate the .rma files for the top 500 KOs only
#--Consolidate the m8 into 1 file and write megan instructions
perl -ne 'chomp; print qq(qsub -V -cwd -b y script/seq.0201.MEGANprep.pl $_ out/seq.0113.v5 out/seq.0118 /export2/home/uesu/sequencing.output/../downloads/gi_taxid_prot.bin\n)' data/top500kos.txt 
#--Executes the instructions 
perl script/seq.0202.batchMEGAN.pl /export2/home/uesu/downloads/MEGAN5-academic-license.txt data/top500kos.txt | sh

#perl -nle 'BEGIN{$i=1} print qq(qsub -V -cwd -b y ./blast2rma.sh out/seq.0118/$_ out/seq.0118/$_\_.rma $i /export2/home/uesu/downloads/MEGAN5-academic-license.txt);$i++' <(tail -n50 data/top500kos.txt) | sh

#Step 2: generate the list of taxa (under taxID=2; falling under bacteria) and the no. of reads assigned to it. 
#generates MEGAN instruction
qsub -V -cwd -b y script/seq.0220.generate.counts.pl data/top500kos.txt
#run the instructions
ls out/seq.0220/ | perl -ne 'BEGIN{$i=1} chomp; print qq(qsub -V -cwd -b y \047xvfb-run -n $i /export2/home/uesu/megan/MEGAN -g -d -E -c /export2/home/uesu/sequencing.output/out/seq.0220/$_ -L /export2/home/uesu/downloads/MEGAN5-academic-license.txt\047\n); $i++;' | sh

#Step3: Output the reads for that nodes belonging to that rank's 
#output instructions
perl -ne 'chomp; print qq(qsub -V -cwd -b y \047./script/seq.0221.paths.r $_ family\047\n)' data/top500kos.txt | sh
#run MEGAN
perl -ne 'BEGIN{$i=1} chomp; print qq(qsub -V -cwd -b y \047xvfb-run -a -n $i /export2/home/uesu/megan/MEGAN -g -d -E < /export2/home/uesu/sequencing.output/out/seq.0118/$_-binary-instructions -L /export2/home/uesu/downloads/MEGAN5-academic-license.txt\047\n); $i++' data/top500kos.txt


