#!/usr/bin/env Rscript

library(Metamaps)
library(RColorBrewer)
library(igraph)
library(RJSONIO)
library(RCurl)
library(gridExtra)
library(dplyr)
library(data.table)
library(ggplot2)
library(scales)

dir.create("out/seq.0260")
load("~/sequencing.output/out/seq.0250.out.rda")
#load("~/abu_genes/data/de.0100.layout.rda")
load("/export2/home/uesu/github/ComplexCommunities/Abundance/data/layout.rda")

#Draw graph from top500 KOs
##Top500 KOs
load("~/abu_genes/data/Abundance_Function/mRNA.1000.genus.rda")
top500.c1.mean=arrange(summarise(group_by(filter(genus, ko != 'K00000'),ko), c1.mean=sum(c1.mean)), desc(c1.mean))
####################################################################################################

##Calling the neo4j
query1="start ko=node:koid(ko={koid}) match ko<--(cpd:`cpd`) return ko.ko,cpd.cpd"
query2="start ko=node:koid(ko={koid}) match ko-->(cpd:`cpd`) return ko.ko,cpd.cpd"

##Edgelist
kolist=top500.c1.mean$ko[1:500]
results.dir1=do.call(rbind,lapply(paste("ko:",kolist,sep=""), function(x) {
param=x
post=toJSON(
	    list(
		query=query1,
		params=list(koid=param)
		)
	    )
result=fromJSON(
	getURL("http://192.168.100.1:7474/db/data/cypher", 
	customrequest='POST', 
	httpheader=c('Content-Type'='application/json'), 
	postfields=post
	)
	)
do.call(rbind,result$data)
}))
results.dir1=results.dir1[,2:1]

results.dir2=do.call(rbind,lapply(paste("ko:",kolist,sep=""), function(x) {
param=x
post=toJSON(
	    list(
		query=query2,
		params=list(koid=param)
		)
	    )
result=fromJSON(
	getURL("http://192.168.100.1:7474/db/data/cypher", 
	customrequest='POST', 
	httpheader=c('Content-Type'='application/json'), 
	postfields=post
	)
	)
do.call(rbind,result$data)
}))
edgelist=rbind(results.dir1, results.dir2)
neo4j.g.mRNA=simplify(graph.data.frame(edgelist))


#Names###################
load("~/abu_genes/data/Abundance_Function/ko.name.rda")
ko.df=subset(ko.name, ko %in% gsub("ko:","",grep("ko:",V(neo4j.g.mRNA)$name,value=T)))
V(neo4j.g.mRNA)$ko.label=ko.df$symbol[match(V(neo4j.g.mRNA)$name, paste("ko:",ko.df$ko, sep=""))]
V(neo4j.g.mRNA)$ko.label[is.na(V(neo4j.g.mRNA)$ko.label)]<-""
####################################################################################################

#Layout::Unfinished
#layout.df=setNames(data.frame(V(g.mRNA)$name, layout.norm(b1layout)), c("vertex","x","y"))
#save(layout.df, file="/export2/home/uesu/github/ComplexCommunities/Abundance/data/layout.rda")
#Coloring on the diversity index
#Base on old layout###########################################################################################
final.layout=setNames(
	do.call(cbind,lapply(c(Inf, -Inf), function(x) {
		combined.df=merge(data.frame(vertex=V(neo4j.g.mRNA)$name), layout.df,by="vertex",all.x=T)
		combined.df[is.na(combined.df)]<-x
		combined.df
   		}))[,-4] , 
	c("vertex","maxx","maxy","minx","miny")
	)

final.layout=final.layout[match(V(neo4j.g.mRNA)$name, final.layout$vertex),]
final.layout2=layout.fruchterman.reingold(neo4j.g.mRNA, minx=final.layout$minx, maxx=final.layout$maxx, miny=final.layout$miny, maxy=final.layout$maxy)
#############################################################################################################
#New layout##################################################################################################
newlayout=layout.fruchterman.reingold(neo4j.g.mRNA)
##############################################################################################################

#Diversity index
metabolism=subset(diversity_index, ko %in% gsub("ko:","",grep("ko:",V(neo4j.g.mRNA)$name,value=T)))
metabolism$totalglos = metabolism$no.of.glos + metabolism$no.of.genera
pdf("out/seq.0260/seq.0260.diversity_density.pdf")
grid.arrange(
qplot(metabolism$no.of.genera, geom="density"),
qplot(metabolism$no.of.glos,geom="density")
)
dev.off()

color.bar <- function(lut, min, max=-min, nticks=11, ticks=seq(min, max, len=nticks), title='') {
    scale = (length(lut)-1)/(max-min)
#    dev.new(width=1.75, height=5)
    plot(c(0,10), c(min,max), type='n', bty='n', xaxt='n', xlab='', yaxt='n', ylab='', main=title)
    axis(2, ticks, las=1)
    for (i in 1:(length(lut)-1)) {
     y = (i-1)/scale + min
     rect(0,y,10,y+1/scale, col=lut[i], border=NA)
    }
}

#Raw plot
pdf("/out/seq.0260/seq.0260.diversity.metabolicgraph.pdf")
plot(neo4j.g.mRNA,
    vertex.label=V(neo4j.g.mRNA)$name,
    vertex.size=c(1,5)[1*(1:vcount(neo4j.g.mRNA) %in% grep("ko:",V(neo4j.g.mRNA)$name))+1],
    vertex.label.cex=0.1,
    edge.arrow.size=0.1, 
    vertex.frame.color="#FFFFFF00", 
    layout=newlayout
    )
dev.off()
####################################################################################################
metabolism$no.of.genera_class=cut(metabolism$no.of.genera, 
                breaks = seq(0,350, 10) ,
                right=TRUE, include.lowest=TRUE)
no.of.genera_legendlabels=gsub(",","-",gsub("\\[|\\]|\\(","",levels(metabolism$no.of.genera_class)))
metabolism$no.of.genera_class=factor(
	metabolism$no.of.genera_class, 
	levels=as.character(levels(metabolism$no.of.genera_class)),
	labels=colorRampPalette(c("light green", "yellow", "orange", "red"))(length(levels(metabolism$no.of.genera_class)))
)
no.of.genera.vertex.color=as.character(metabolism$no.of.genera_class[match(V(neo4j.g.mRNA)$name , paste("ko:",metabolism$ko,sep=""))])
no.of.genera.vertex.color[is.na(no.of.genera.vertex.color)]<-'black'


pdf("./out/seq.0260/seq.0260.no.of.genera.pdf")
layout(matrix(c(1,1,1,1,2), 1, 5, byrow = TRUE))
plot(neo4j.g.mRNA,
    vertex.label=V(neo4j.g.mRNA)$ko.label,
    vertex.size=c(1,5)[1*(1:vcount(neo4j.g.mRNA) %in% grep("ko:",V(neo4j.g.mRNA)$name))+1],
    vertex.color=no.of.genera.vertex.color,
    vertex.label.cex=0.5,
    edge.arrow.size=0.1, 
    vertex.frame.color="#FFFFFF00", 
    layout=newlayout,
    main="Sum total of genera"
    )
color.bar(colorRampPalette(c("light green", "yellow", "orange", "red"))(length(levels(metabolism$no.of.genera_class))),min=0,max=350)
dev.off()
####################################################################################################

####################################################################################################
metabolism$totalglos_class=cut(metabolism$totalglos, 
                breaks = seq(0,max(metabolism$totalglos), 1000) ,
                right=TRUE, include.lowest=TRUE)
no.of.genera_legendlabels=gsub(",","-",gsub("\\[|\\]|\\(","",levels(metabolism$totalglos_class)))
metabolism$totalglos_class=factor(
	metabolism$totalglos_class, 
	levels=as.character(levels(metabolism$totalglos_class)),
	labels=colorRampPalette(c("light green", "yellow", "orange", "red"))(length(levels(metabolism$totalglos_class)))
	)

totalglo.vertex.color=as.character(metabolism$totalglos_class[match(V(neo4j.g.mRNA)$name , paste("ko:",metabolism$ko,sep=""))])
totalglo.vertex.color[is.na(no.of.genera.vertex.color)]<-'black'

maxlabel=as.integer(unlist(strsplit(no.of.genera_legendlabels[length(no.of.genera_legendlabels)], "-"))[2])

pdf("./out/seq.0260/seq.0260.no.of.glos_genera.pdf")
layout(matrix(c(1,1,1,1,2), 1, 5, byrow = TRUE))
plot(neo4j.g.mRNA,
    vertex.label=V(neo4j.g.mRNA)$ko.label,
    vertex.size=c(1,5)[1*(1:vcount(neo4j.g.mRNA) %in% grep("ko:",V(neo4j.g.mRNA)$name))+1],
    vertex.color=totalglo.vertex.color,
    vertex.label.cex=0.5,
    edge.arrow.size=0.1, 
    vertex.frame.color="#FFFFFF00", 
    layout=newlayout,
    main="Sum total of glos_genera"
    )
color.bar(colorRampPalette(c("light green", "yellow", "orange", "red"))(length(levels(metabolism$totalglos_class))),min=0,max=maxlabel)
dev.off()
####################################################################################################

#The difference in the KOs between my method and xiechaos's methods so lets try again there much more cpds than XC's method i wonder why
#deletedkos=gsub("ko:","",grep("ko",V(g.mRNA.neo4j)$name,value=T)[!grep("ko",V(g.mRNA.neo4j)$name,value=T) %in% grep("ko",V(g.mRNA)$name,value=T) ]) 
#> deletedkos
# [1] "K01130" "K01952" "K01881" "K00799" "K03147" "K02535" "K01845" "K02495"
# [9] "K01887" "K01921" "K02474" "K01712" "K00790" "K01924"
