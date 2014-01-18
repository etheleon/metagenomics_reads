#!/usr/bin/env Rscript
library(RJSONIO)
library(RCurl)
args=commandArgs(T)

#--Database
#library(sqldf)
#climb<-function(x) { 
#sqlcommand=paste("select * from tax2rank where taxid=",x)
#dbGetQuery(dbcoAn, sqlcommand)}
#databasefile="/export2/home/uesu/sequencing.output/data/gi_taxid_prot.db"
#dbcon=dbConnect(dbDriver("SQLite"), dbname=databasefile)

#--Params
KO=args[1]
rank='family'
system(sprintf("echo -e \"LCA.taxid\trank\tGLO\tcount\" > out/seq.0223/%s-%s-GLOS", KO, rank))
familytaxids=system(paste("ls out/seq.0222/",KO,"-",rank,"-* | perl -ne '/\\-(\\d+)/; print qq($1\n)'",sep=""),int=T)

#Queries neo4j DB for the table###################
#--Cypher Queries
#q<-'start bacteria=node:ncbitaxid(\'taxid:2\') match (species:`species`)-[:childof*]->(genus:`genus`)-[:childof*]->(family:`family`)-[childof*]->(order:`order`)-[:childof*]->(class:`class`)-[:childof*]->(phylum:`phylum`)-[:childof*]->bacteria return species.taxid,genus.taxid,family.taxid,order.taxid,class.taxid,phylum.taxid'
#q<-sprintf("start base=node:ncbitaxid(\'taxid:%s\') match base-[:childof*]->(genus:`genus`) return genus.taxid;",'536019')
##################################################

#query<-"start pathway=node:pathwayid(pathway={pathway}) match pathway--(ko:`ko`)<-[r]-(cpd:`cpd`) return ko.ko,cpd.cpd;"
#query<-"start pathway=node:pathwayid(pathway={pathway}) match pathway--(ko:`ko`)<-[r]-(cpd:`cpd`) return ko.ko AS node"
#query<-"start pathway=node:pathwayid(pathway={pathway}) match pathway--(ko:`ko`)<-[r]-(cpd:`cpd`) return cpd.cpd AS node"
params="path:ko00010"
    post=toJSON(
	    list(
		query=query,
		params=list(pathway=params)
		)
	    )

result=fromJSON(
	getURL("http://localhost:7474/db/data/cypher", 
	customrequest='POST', 
	httpheader=c('Content-Type'='application/json'), 
	postfields=post
	)
	)
edges=do.call(rbind,(result$data))
kos=unique(unlist(result$data))
cpd=unique(unlist(result$data))

query <- function(querystring, type) {
  h = basicTextGatherer()
  curlPerform(url="http://metamaps.scelse.nus.edu.sg:7474/db/data/cypher",
    postfields=paste('query',curlEscape(q), sep='='),
    writefunction = h$update,
    verbose = FALSE
  )           
 result= fromJSON(h$value())
 result= unlist(fromJSON(h$value()))

if(length(result)==2){
result[[2]]
}
}

lapply(familytaxids, function(xx){ 	#for each family
	node=xx
	filetoprocess=sprintf("out/seq.0222/%s-%s-%s-ex2.txt",KO,rank,node)	
	filetoopen=sprintf("out/seq.0222/%s-%s-%s-ex2.txt",KO,rank,node)	
	if(file.info(filetoopen)$size != 0) { 
	
	#----Start processing the file----#
	allMatches=setNames(read.table(file=filetoopen,sep="\t",comment.char=""),c("Read.ID","taxid","score"))
	allMatches=subset(allMatches, taxid!=0) #removed unassigned matches
	allMatches=do.call(rbind,lapply(unique(allMatches$Read.ID), function(read) { 
		    per.read=subset(allMatches, Read.ID == read)
		    assigned.taxa=subset(per.read, score >= 0.9*max(per.read$score) & score > 35)
	}))


#Find GLOs
glo=ddply(na.omit(setNames(do.call(rbind,apply(allMatches,1 , function(x) { 
		    q<-sprintf("start base=node:ncbitaxid(\'taxid:%s\') match base-[:childof*]->(genus:`genus`) return genus.taxid;",x[[2]])
		    genus=query(q)
		    data.frame(x[[1]], ifelse(length(genus), genus, NA),stringsAsFactors=F)
		    })), 
		    c("read","genus"))), 
		    "read", function(x) { paste(sort(unique(x$genus)),collapse="_") })
glo2=cbind(data.frame(LCA.taxid=node,rank=rank,no.of.reads=nrow(glo)),setNames(data.frame(table(glo$V1)),c("GLO","Freq")))
write.table(glo2, file=sprintf("out/seq.0223/%s-%s-GLOS", KO, rank), quote=F,row.names=F, col.names=F,append=T,sep="\t")
}
})
#assigned.reads=do.call(rbind,
#
#	    mclapply(unique(allMatches$Read.ID), function(x) { 
#		    per.read=subset(allMatches, Read.ID == x)
#		    assigned.taxa=subset(per.read, score >= 0.9*max(per.read$score) & score > 35)$taxid 
#		    #met the bitscore requirement of being above the threshold and above top10perc 
#####################################################################################################   
##		    for (y in assigned.taxa){ #foreach of the matched taxa work your way up to the parent node
#		   data.frame(
#		   read=x, 
#		   paths=sapply(assigned.taxa, function(y){ 
#		    tax.string=y		#the starting spp node
#		    while(y!=node)	{
#	    		if (y==1) { #if it hits root
#	    		    break #if it goes up and cannot find the parent family 
#	    		    }else{ #continue climbing
#	    		    y<-climb(y)$parentid
#	    		    #-- tax.string stores the 
#		    	    tax.string<-c(y,tax.string)
#		    	    }
#		    }
#		    #put all paths belonging to a read into a list
#		    if(1 %in% tax.string){
#		    	0
#		    }else{
# 	    	    paste(tax.string,collapse="_")
# 	    	    }
#		    }))
#####################################################################################################   
#	    }))
#assigned.reads=as.data.frame(assigned.reads)
#assigned.reads=subset(assigned.reads, paths != 0)
#assigned.reads$paths<-droplevels(assigned.reads$paths)
#
##Output1
##filetowriteto1=sprintf("out/seq.0223/%s-%s-paths",KO,rank,node)
##nonsense=setNames(data.frame(node=node,melt(table(assigned.reads$paths))), c("Node","Path","count")) 
##write.csv(nonsense, file=filetowriteto1,row.names=FALSE,append=T)
##
##Output2
##filetowriteto2=sprintf("out/seq.0223/%s-%s-GLOS",KO,rank,node)
#df.penultimate=ddply(assigned.reads, "read", function(x) { 
#path=paste(sort(as.integer(unique(do.call(c,
#lapply(x$paths, function(x) { unlist(strsplit(as.character(x), "_"))[2] }))))), collapse="_") 
##because i only am interested in the base
#data.frame(read=unique(x[,1]), path=path)
#})
##write.table(df.penultimate, file=filetowriteto2, row.names=FALSE,append=T,quote=F,sep="\t")	
#
##The summary of the pass through ie the no. of genus like objects
#filetowriteto3=sprintf("out/seq.0223/%s-%s-GLOS",KO,rank,node)
#pen.summary=setNames(data.frame(node, rank, melt(table(df.penultimate$path))), c("LCA.taxid","rank","GLO", "count"))
#write.table(pen.summary, file=filetowriteto3, col.names=F,row.names=FALSE,append=T,quote=F,sep="\t")
#}
#})
