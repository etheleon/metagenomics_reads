less mRNA.0020.m8/b2-0058_s_3.1.m8.bz2 | perl -ne 'if(!/^\#/ && m/\|ref\|/) { m/^(\S+)\/\d\t/; $counting{$1}++} END{foreach $key (sort keys %counting) {print "$key\t$counting{$key}\n" }}'
