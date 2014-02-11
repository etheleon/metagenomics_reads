#!/usr/bin/env Rscript
library(RJSONIO)
library(RCurl)
library(gridExtra)
library(dplyr)
library(data.table)
library(ggplot2)
library(scales)

#glo.bigtable=fread(input="~/Desktop/seq.0252.out",colClasses=c("character","character","integer","integer","integer"),sep="\t",h=TRUE)
glo.bigtable=fread(input="out/seq.0252.out",colClasses=c("character","character","integer","integer","integer"),sep="\t",h=TRUE)
#reading the data in
new.glo.bigtable=filter(glo.bigtable, genusLCAable == 0)				#includes both unclassifiable (hence GLOs)
#new.glo.bigtable=filter(glo.bigtable, genusLCAable == 1)				#includes both classifiable reads (to genus) and unclassifiable (hence GLOs)
#Note in XC's data.frame genus, theres 744 genus and in my table is also 700+

#glos<-group_by(new.glo.bigtable,glo)
glos_everything<-group_by(glo.bigtable,glo)	#you want everything
new.glo.bigtable<-arrange(
	summarise(glos_everything, 
#	summarise(glos, 
		    no.of.kos=n(), 
		    total.reads=sum(read.count,na.rm=T), 
		    familyLCAable=unique(familyLCAable)
		), desc(total.reads))

thresholded<-filter(new.glo.bigtable, total.reads > 5)		#you have you have at least 5 reads
thresholded$family=0
thresholded$family[which(thresholded$familyLCAable == 1)]=1		#if you're LCAable at family you get 1
thresholded$read.perc=thresholded$total.reads/sum(thresholded$total.reads)
annotated= filter(thresholded, total.reads > 10000 | no.of.kos > 200)		#annotated if you're kickass

query='start n=node:ncbitaxid(taxid={taxid}) return n.name'

annotated$gloID=sapply(strsplit(annotated$glo,"_"), function(x) { 
	paste(sapply(x, function(glonum) { 
Querying neo4j ####################################
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

unlist(result$data)
	}), collapse="_")
    })

Plotting
p0=ggplot(thresholded,aes(x=no.of.kos, y=total.reads,shape=as.factor(family)))+
geom_point(alpha=0.05)+
geom_point(data=annotated, aes(no.of.kos, total.reads),alpha=0.5)+
geom_text(data=annotated, aes(label=as.character(gloID)),size=2,color='red')+
geom_rug(col=rgb(.5,0,0,alpha=.01))+
scale_shape_discrete(name="Resolvable at Family Rank")+
scale_y_continuous(trans=log_trans(base=10),breaks=c(1,10,100,10000,50000,100000))+
theme_bw()+
xlab("Occurrence (#KO)")+
ylab("Contribution (#read count)")

ggsave(p0,file="out/seq.0250.kofreqXreads_GLOsonly.png",w=10,h=10)
save(glo.bigtable, annotated, new.glo.bigtable, file="out/seq.0250.out.rda")

#Summary
#Step1: How much (proportion) of the reads are classifiable at the genus lvl.
#> sum(filter(glo.bigtable, genusLCAable == 1)$read.count)/sum(glo.bigtable$read.count)
#[1] 0.09583362
#10%

#Step2: How much (proportion) of the reads are classifiable at the GLO lvl.
#> 1-sum(filter(glo.bigtable, genusLCAable == 1)$read.count)/sum(glo.bigtable$read.count)
#[1] 0.9041664
#90%

#Step3: How does that change the global landscape.
####################################################################################################
#proportion.per.ko
proportion.per.ko=group_by(glo.bigtable, ko)
proportion.per.ko=arrange(summarise(proportion.per.ko, 
	summed.read.count=sum(read.count),
	    glo_proportion=sum(read.count[which(genusLCAable!=0)])/sum(read.count)), desc(glo_proportion)) #the proportion of reads coming from GLOs

load("~/abu_genes/data/Abundance_Function/ko.name.rda")
proportion.per.ko=merge(proportion.per.ko,ko.name,by="ko")
rank.per.ko=arrange(proportion.per.ko, desc(summed.read.count))
rank.per.ko$rank=1:nrow(rank.per.ko)
write.csv(rank.per.ko,file="~/Desktop/seq.0250.perc.glocontribution.per.ko.csv")

#scatteplot the proportion of GLOs and the proportion of reads coming from GLOs
rank.per.ko$ko=factor(rank.per.ko$ko, levels=as.character(rank.per.ko$ko))
p1=ggplot(rank.per.ko,aes(ko,glo_proportion))+
geom_point()+
geom_text(data=subset(rank.per.ko, glo_proportion > quantile(rank.per.ko$glo_proportion, 0.95)), aes(x=ko, y=glo_proportion, label=name),size=2,hjust=0,vjust=0)+
scale_x_discrete(name="KO", labels=as.character(rank.per.ko$symbol))+
scale_y_continuous(label=percent)+
theme(axis.text.x = element_text(size=2, angle = 45, hjust = 1))+
xlab("KOs")+ylab("Expression contribution (GLO/Total)")+ggtitle("Sorted by expression abundance")

rank.per.ko$ko=factor(rank.per.ko$ko, levels=as.character(arrange(rank.per.ko, desc(glo_proportion))$ko))	#the rank 
p2=ggplot(rank.per.ko,aes(ko,glo_proportion))+
geom_point()+
geom_text(data=subset(rank.per.ko, glo_proportion > quantile(rank.per.ko$glo_proportion, 0.95)), aes(x=ko, y=glo_proportion, label=name),size=2,hjust=0,vjust=0)+
scale_x_discrete(name="KO", labels=as.character(rank.per.ko$symbol))+
scale_y_continuous(label=percent)+
theme(axis.text.x = element_text(size=2, angle = 45, hjust = 1))+
xlab("KOs")+ylab("Expression contribution (GLO/Total)")+ggtitle("Sorted by GLO contribution")

pdf("out/seq.0250.koVSgloXtotalproportion.out.pdf",w=15)
grid.arrange(p1,p2, ncol=2)
dev.off()
####################################################################################################

#add in the rank
#Step4: Which KOs are most affected by this. 
quantiledf=do.call(rbind,
	       lapply(seq(0,1,by=0.01)[-1], function(x) { 
       			  thisquantile=filter(thresholded,read.perc >= quantile(thresholded$read.perc,x-0.01) & read.perc <= quantile(thresholded$read.perc,x) ) 
       			  if(nrow(thisquantile)>0){
       			  data.frame(
       			  quantile=x,
       			  ingenus=sum(sapply(strsplit(thisquantile$glo, "_"), function(x) length(x)==1))/nrow(thisquantile),
			  infamily=sum(thisquantile$family==1)/nrow(thisquantile)	) 	#the perc of genus/total
			  }
	})
	       )
p3=ggplot(quantiledf, aes(quantile,ingenus))+
geom_point()+
xlab("Percentile")+ylab("Proportion of Genus/GLO entites resolvable at the genus rank")+
scale_y_continuous(label=percent)
p4=ggplot(quantiledf, aes(quantile,infamily))+geom_point()+
xlab("Percentile")+ylab("Proportion of Genus/GLO entites resolvable at the family rank")+
scale_y_continuous(label=percent)

pdf("/out/seq.0250.byquantile.pdf",w=15)
grid.arrange(p3,p4,ncol=2)
dev.off()
