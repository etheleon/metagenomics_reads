#!/usr/bin/env Rscript

metabkos<-setNames(read.csv("data/reads.metabko.only.csv",h=F,stringsAsFactors=F), c("read","ko"))
colnames(metabkos)<-c("read","ko")
#reads which are classifiable at the genus level

#Method1:Fail
#awk {'print $2'} data/classifiable_reads/taxa.Genus.txt |sort|uniq > data/kos.classifiable_at_genus.txt
#classifiable_kos<-read.table("./data/kos.classifiable_at_genus.txt",h=F)
#Dead end: all metab KOs are mappable to some genus as some in some point in time
#double check: look for KOs which are not classifiable @ all for any genus. 
#'K07354' %in% as.character(classifiable_kos$V1)

classifiable<-setNames(read.csv("data/classifiable_reads/taxa.Genus.csv",h=F), c("read","ko","genus"))

#--Summary 
#The no. of metabko reads not associated with any genera: 7630500; classifiable reads = 32776
#	    > sum(!as.character(metabkos$read) %in% as.character(classifiable$read))
#	    [1] 7630500
#	    > nrow(metabkos)
#	    [1] 7663276
#	    > nrow(metabkos) - 7630500
#	    [1] 32776

metab_uncl<-metabkos[!as.character(metabkos$read) %in% as.character(classifiable$read),]

cat(with(metab_uncl, sprintf("%s\t%s",ko, read)), file="data/metab_uncl.txt",sep="\n")

#next step: search the megan output file for the reads
