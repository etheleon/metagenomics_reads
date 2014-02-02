#!/usr/bin/env Rscript
library(RJSONIO)
library(RCurl)
library(gridExtra)
library(dplyr)
library(data.table)
library(ggplot2)
library(scales)

#reading the data in
glo.bigtable=fread(input="out/seq.0248.out",colClasses=c("character","character","integer","integer"),sep="\t",h=T)
new.glo.bigtable=filter(glo.bigtable, genusLCAable == 0)				#includes both classifiable reads (to genus) and unclassifiable (hence GLOs)

glos<-group_by(new.glo.bigtable, glo)
new.glo.bigtable<-arrange(summarise(glos, no.of.kos=n(), total.reads=sum(read.count,na.rm=T)), desc(total.reads))

thresholded<-filter(new.glo.bigtable, total.reads > 5)
annotated= filter(thresholded, total.reads > 10000 | no.of.kos > 200)

query='start n=node:ncbitaxid(taxid={taxid}) return n.name'



annotated$gloID=sapply(strsplit(glo,"_"), function(x) { 
	paste(sapply(x, function(glonum) { 
#Querying neo4j ####################################
post=toJSON(
            list(
                query=query,
                params=list(taxid=glonum)
                )
            )
result=fromJSON(
        getURL("http://192.168.100.1:7474/db/data/cypher",
        customrequest='POST',
        httpheader=c('Content-Type'='application/json'),
        postfields=post
        )
        )
##################################################
unlist(result$data)
	}), collapse="_")
    })

#Plotting
p0=ggplot(thresholded,aes(no.of.kos, total.reads))+
geom_point(alpha=0.05)+
geom_point(data=annotated, aes(no.of.kos, total.reads),alpha=0.5)+
geom_text(data=annotated, aes(label=as.character(gloID)),size=2,color='red')+
geom_rug(col=rgb(.5,0,0,alpha=.01))+
scale_y_continuous(trans=log_trans(base=10),breaks=c(1,10,100,10000,50000,100000))+
theme_bw()+
xlab("Occurrence (#KO)")+
ylab("Contribution (#read count)")

ggsave(p0,file="out/seq.0250.kofreqXreads.png",w=10,h=10)
save(annotated, new.glo.bigtable, file="out/seq.0250.out.rda")
