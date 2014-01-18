#!/usr/bin/env Rscript

#export what=DSV format=readname_matches separator=tab file='' this if for

#node taxid=126 in K01915 glutamine synthetase
#perl -aln -F"\t" -e '$readid=$F[0]; shift @F; while(scalar @F > 0) {$i=scalar @F; print qq($readid\t$F[$i-2]\t$F[$i-1]); pop @F; pop @F}' K01915-readname_count.txt | head
library(sqldf)
databasefile="/export2/home/uesu/sequencing.output/data/gi_taxid_prot.db"
dbcon=dbConnect(dbDriver("SQLite"), dbname=databasefile)

allMatches<-setNames(read.table("K01915-readname_count_df.format.txt",sep="\t",comment.char=""),c("Read.ID","taxid","score"))

#Find the parent until its the node ie. in this case 126 
climb<-function(x) { 
sqlcommand=paste("select * from tax2rank where taxid=",x)
dbGetQuery(dbcon, sqlcommand)
}

assigned.reads=do.call(rbind,
lala=lapply(unique(allMatches$Read.ID), function(x) { 
	per.read=subset(allMatches, Read.ID == x)
	#df=data.frame(read=x,taxids=
	assigned.taxa=subset(per.read, score >= 0.9*max(per.read$score) & taxid!=0)$taxid 
	#met the bitscore requirement top10perc & not matched to unknown
	
	for (y in assigned.taxa){ #foreach of the base taxa 
	tax.string=y
	while(y!=126){ 
#climbs up the tree to genus
	y<-climb(y)$parentid
	tax.string<-c(y,tax.string)
	}
	#put all paths belonging to a read into a list	
	if(exists("all.trees")){ 
	all.trees=c(all.trees,paste(tax.string, collapse="_"))	
	}else{all.trees=paste(tax.string, collapse="_")
	}
	tax.string=""
	}
df= data.frame(read=x, paths=all.trees)
rm(all.trees)
df
})
	)
