#!/usr/bin/env Rscript

#load taxGIFile='/export2/home/uesu/downloads/gi_taxid_prot.bin';
#import blastFile='/export2/home/uesu/sequencing.output/out/seq.0118/K09458.m8' meganFile='/export2/home/uesu/sequencing.output/out/seq.0118/K09458.rma' maxMatches=100 minScore=50.0 maxExpected=1.0 topPercent=10 minSupport=5 minComplexity=0.44 useMinimalCoverageHeuristic=false useSeed=false useCOG=false useKegg=false paired=false useIdentityFilter=false textStoragePolicy=0 blastFormat=BlastTAB mapping='Taxonomy:GI_MAP=true,KEGG:GI_MAP=false';

#MEGAN#################################################################################################### 
#open the KO
#open file='/export2/home/uesu/sequencing.output/out/seq.0118/K09458.rma';
#unCollapse nodes=all;
#select nodes=all;
#export what=DSV format=taxonid_count separator=tab counts=summarized file='/export2/home/uesu/sequencing.output/out/seq.0118/K09458_taxonid_count' 
#export what=DSV format=taxonid_count separator=tab counts=summarized file='/export2/home/uesu/sequencing.output/out/seq.0221/K01915.rma' 
##########################################################################################################

library(sqldf)

#Part1 Background statistics::Per KO basis##############################
#--Statistic of actualy vs theoretical no. of taxa (1 rank down from that specified) with reads mapped to it. 

#import into R #summarised counts
a<-read.csv("out/seq.0118/K09458_taxonid_count",sep="\t")
colnames(a)<-c("taxid","count")

#Find all belonging to the rank of interest

ranks=c("phylum","class","order","family","genus")
rankss=c("Phylum","Class","Order","Family","Genus")
databasefile="/export2/home/uesu/sequencing.output/data/gi_taxid_prot.db"
dbcon=dbConnect(dbDriver("SQLite"), dbname=databasefile)

wl=do.call(rbind,lapply(ranks, function(xx) { 
rank=xx
#--Return all NODES.OF.INTEREST at given RANK
sqlcommand=paste('select * from tax2rank where taxid IN (', paste(a$taxid[-length(a$taxid)],collapse=",") ,') and rank=\'', rank, '\'',sep="")
nodes.of.interest=dbGetQuery(dbcon, sqlcommand)
nodes.of.interest=nodes.of.interest$taxid

#Query db again for child nodes of NODES.OF.INTEREST 
sqlcommand=paste('select * from tax2rank where parentid IN (', paste(nodes.of.interest, collapse=","), ')') 
underthesenodes=dbGetQuery(dbcon, sqlcommand)

#the max no. in NCBI
theory=setNames(ddply(underthesenodes, "parentid", nrow), c("Parent","Child.theory"))

#the actual no. in the tree
#a$taxid[which(a$taxid %in% underthesenodes$taxid)]

#the actual no. in the data
actual=setNames(do.call(rbind,lapply(unique(underthesenodes$parentid), function(x) { data.frame(parentid=x, child=length(a$taxid[which(a$taxid %in% subset(underthesenodes, parentid==x)$taxid)]) )})), c("Parent", "Child.actual"))

comparison=merge(theory, actual)
comparison$ratio=comparison$Child.actual/comparison$Child.theory 
comparison=data.frame(comparison, rank=rank) 
}))

#Plot the details
pdf("out/seq.0118.pdf/K09458.pdf"); ggplot(aes(x=rank, y=ratio),data=wl) + geom_boxplot(aes(fill=rank))+ylab('Ratio (actual/full)') ;dev.off()

#XC gave comment that you shd show also the absolute no. 
####################################################################################################
#Part2:
i=2

#MEGAN#################################################################################################### 
#output the the match signatures for each rank

df=subset(wl, rank == ranks[i])

#OUTPUT SIGNATURES at this lvl, 
write(c("open file='/export2/home/uesu/sequencing.output/out/seq.0118/K09458.rma';","unCollapse nodes=all;select nodes=all;",do.call(c,lapply(df$Parent, function(x) 
sprintf('export what=matchPatterns taxon=%s rank=%s file=%s', x, rankss[i+1], sprintf('/export2/home/uesu/sequencing.output/out/seq.0118/K09458_%s_binary_taxid:%s',rankss[i],x))
)),"quit;"),file="batch_megan") #need to change the file

#run it in megan 
#ls out/seq.0118/*.rma | perl -ne 'chomp; print q(open file=/export2/home/uesu/sequencing.output/); print $_; print qq(;\n); print qq(unCollapse nodes=all;\nselect nodes=all;\n); print qq(export what=DSV format=taxonid_count separator=tab counts=assigned file=\047/export2/home/uesu/sequencing.output/$_.count\047;\n)' >batch_megan2


files=system("ls out/seq.0118/*.rma.count",intern=T)

a<-do.call(rbind,lapply(files, function(x) {
ko=gsub("^.+(K\\d+)\\.rma\\.count", "\\1", x)
df=read.table(file=x,sep="\t")
#reads for things above genus
sqlcommand=sprintf("select * from tax2rank where taxid IN (%s) and rank NOT IN ('species', 'genus', 'species group')", paste(df$V1[-length(df$V1)], collapse=","))
above.genus=dbGetQuery(dbcon, sqlcommand)
neither=sum(subset(df, V1 %in% above.genus$taxid)$V2)
unassigned=subset(df, V1 == -2)$V2
assigned=sum(subset(df, V1 !=-2)$V2)
#things which are assignable above genus
data.frame(unassigned=unassigned, assigned=assigned, above.genus=neither,ko=ko)
}))

a$genusNbelow=a$assigned - a$above.genus
b<-melt(new.a)
b$ko<-factor(b$ko, levels=as.character(new.a$ko[order(new.a$unassigned,decreasing=T)]))

pdf("./out/seq.0210.read.assignment.pdf")
qplot(x=ko, y=log10(value),position="dodge", fill=variable,geom="bar",data=b)+ylab("Absolute count (log10)")+xlab("KOs")+scale_fill_brewer(name="Assignment",type="qual",palette="Set1")
dev.off()
