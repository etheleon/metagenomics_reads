for i in `ls out/seq.0241/*`; do 
    			   perl -aln -F"\t" -e 'BEGIN{$ARGV[0] =~ /(K\d+)/; $ko=$1} $glo{$F[3]}++; END{foreach (keys %glo) {print "$ko\t$_\t$glo{$_}" }}' $i 
    			   done;
