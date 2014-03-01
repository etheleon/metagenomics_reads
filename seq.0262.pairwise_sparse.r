#!/usr/bin/env Rscript

library(knitr)
library(data.table)
library(Matrix)
library(Metamaps)
library(ggplot2)
library(dplyr)
library(scales)
library(igraph)
dir.create("/export2/home/uesu/sequencing_output/out/seq.0262")
data(top500kos)
load("/export2/home/uesu/sequencing_output/data/og.0701.count.rda")	#Cluster data

#'Summary Looking at the Diversity of the KOs in tersm of GLOs and Clusters. Also 

#+KOPairs, cache=TRUE
pairwise=pairkos(cypherurl="192.168.100.1:7474",ko=top500kos)
pairwise=pairwise[which((pairwise[,1] %in% top500kos) * (pairwise[,2] %in% top500kos) == 1),]	#Remove not in tht top 500

#+Metab-graph-KEGG14_top500, cache=TRUE
g.mRNA=grepgraph(cypherurl='192.168.100.1:7474',kos=top500kos)
V(g.mRNA)$ko.label=V(g.mRNA)$Definition
V(g.mRNA)$ko.label[grep("ko:",V(g.mRNA)$name,invert=T)]<-""
g.mRNA$layout=layout.fruchterman.reingold(g.mRNA)

#'Summary XC's KO against cluster information
summary(data)

#+Diveristy-Distribution
kos.in.graph=gsub("ko:","",grep("ko:", V(g.mRNA)$name, value=T))
g.ko.clusterinfo=	group_by(data) %.%
    			filter(ko %in% kos.in.graph) %.%
			arrange(desc(ncut))
g.ko.clusterinfo$ko = factor(g.ko.clusterinfo$ko, levels=as.character(g.ko.clusterinfo$ko))

#+ClusterDiversity_Distribution, fig.cap='Cluster size across KOs'
qplot(ko,ncut,data=g.ko.clusterinfo)+ylab("No. of Clusters")+xlab("KOs")

#+Colorbar
color.bar <- function(lut, min, max=-min, nticks=11, ticks=seq(min, max, len=nticks), title='') {
    scale = (length(lut)-1)/(max-min)
    plot(c(0,10), c(min,max), type='n', bty='n', xaxt='n', xlab='', yaxt='n', ylab='', main=title,cex.main=1.5)
    axis(2, ticks, las=1)
    for (i in 1:(length(lut)-1)) {
     y = (i-1)/scale + min
     rect(0,y,10,y+1/scale, col=lut[i], border=NA)
    }
}

g.ko.clusterinfo$ncut_class=cut(g.ko.clusterinfo$ncut, 
                breaks	=seq(0,3100, 100) ,
                right	=TRUE, include.lowest=TRUE)
legendlabels=gsub(",","-",gsub("\\[|\\]|\\(","",levels(g.ko.clusterinfo$ncut_class)))

g.ko.clusterinfo$ncut_class=factor(
	g.ko.clusterinfo$ncut_class, 
	levels=as.character(levels(g.ko.clusterinfo$ncut_class)),
	labels=colorRampPalette(c("light green", "yellow", "orange", "red"))(length(levels(g.ko.clusterinfo$ncut_class)))
)
cluster.vertex.color=as.character(g.ko.clusterinfo$ncut_class[match(V(g.mRNA)$name, paste("ko:",g.ko.clusterinfo$ko,sep=""))])
cluster.vertex.color[is.na(cluster.vertex.color)]<-'black'

#+MetabNetworkXCluster_Diversity, fig.cap='Cluster based Diveristy Index'
layout(matrix(c(1,1,1,1,2,1,1,1,1,3), 2, 5, byrow = TRUE))
plot(g.mRNA,
    vertex.label=V(g.mRNA)$ko.label,
    vertex.size=c(1,5)[1*(1:vcount(g.mRNA) %in% grep("ko:",V(g.mRNA)$name))+1],
    vertex.color=cluster.vertex.color,
    vertex.label.cex=0.2,
    edge.arrow.size=0.1, 
    vertex.frame.color="#FFFFFF00", 
    main="# of Clusters"
    )
color.bar(colorRampPalette(c('red','orange','yellow','light green'))(length(levels(g.ko.clusterinfo$ncut_class))),min=0,max=3100)

##/* 
#To generate the pdf run the following
opts_chunk$set(echo=FALSE,warning=FALSE,error=FALSE,message=FALSE,out.width='0.8\\linewidth',width = 50,
root.dir = '/export2/home/uesu/sequencing_output',fig.path='/export2/home/uesu/sequencing_output/out/seq_0262/seq_0262-',cache.path='/export2/home/uesu/sequencing_output/markdown/seq.0262/')
spin(hair='script/seq.0262.pairwise_sparse.r',format='Rnw',knit=FALSE)
knit2pdf(input="script/seq.0262.pairwise_sparse.Rnw")

##*/
