#!/usr/bin/env Rscript
#Fxn of this script: get megan to output the reads associated with 

library(sqldf)
args=commandArgs(T) #KO & #rank
ko=args[1]
rank=args[2] #lowercase

#Function which gives all possible combinations 
    all.possible.routes=function(y) { 
    	yy=length(y)
    	    lapply(1:yy, function(xx) { 
    		    combination<-combn(1:yy, xx)
		    matrix(y[combination], ncol=ncol(combination))
    		    })
    }
climb<-function(x) { 
    sqlcommand=paste("select * from tax2rank where taxid=",x)
	dbGetQuery(dbcon, sqlcommand)
}

#NOTE not solved the output for the example is BLEAH

#Setting up DB connection 
databasefile="/export2/home/uesu/sequencing.output/data/gi_taxid_prot.db"
dbcon=dbConnect(dbDriver("SQLite"), dbname=databasefile)

#import taxids for given KO::K01915
all.nodes.ori<-setNames(read.table(sprintf("out/seq.0221/%s.count",ko)), c("taxid","summarised.counts"))
all.nodes<-all.nodes.ori[-nrow(all.nodes.ori),] #to remove unassigned

##-- All nodes in tree w/c belonging to genus
#sqlcommand=	paste(
#	'select * from tax2rank where taxid IN (', 
#		paste(all.nodes$taxid, collapse=","), 
#		') and rank=\'', 
#		'genus', 	#the genus you're interested in 
#		'\''
#		,sep="")
#taxa.genus=dbGetQuery(dbcon, sqlcommand)

sqlcommand=	paste(
	'select * from tax2rank where taxid IN (', 
		paste(all.nodes$taxid, collapse=","), 
		') and rank=\'', 
		rank, 	#the genus you're interested in 
		'\''
		,sep="")
#-- All nodes in the tree belonging to family
taxa.family=dbGetQuery(dbcon, sqlcommand)

#-- Remove the non bacteria family taxa 
checking=do.call(rbind,lapply(taxa.family$taxid, function(y) { 
starting.taxa=y
tax.string=y
while(y!=2){ 
    if(y==1){ 
    	df=data.frame(taxid=starting.taxa,bacteria='no')
    	break
    }else{
    	y<-climb(y)$parentid
    	tax.string<-c(y,tax.string)
    }
    	df=data.frame(taxid=starting.taxa, bacteria='yes')
}
df
})
)
if(length(checking) > 0){
##############################################################################
#Offload to Megan
##Open file-> select bacteria -> uncollapse everything under that 
cat(sprintf("open file=\047/export2/home/uesu/sequencing.output/out/seq.0118/%s.rma\047;\nselect nodes=none;\nselect id=2;\nunCollapse nodes=selected subtree=true;\n",ko), 
file=sprintf("out/seq.0118/%s-binary_instructions",ko))
#output for each node
cat(sapply(subset(checking,bacteria=='yes')$taxid, function(x) { 
sprintf("select nodes=none;
select id=%s;
export what=DSV format=readname_matches separator=tab file=\047/export2/home/uesu/sequencing.output/out/seq.0118/%s-family-%s-ex.txt\047;", x,ko,x)}), file=sprintf("out/seq.0118/%s-binary_instructions",ko),append=T,sep="\n")
cat(sprintf("quit;\n"), file=sprintf("out/seq.0118/%s-binary_instructions",ko),append=T)
##############################################################################
}
