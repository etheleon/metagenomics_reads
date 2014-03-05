#!/usr/bin/env Rscript

#' ANALYSIS: DIVERSITY OF KOS IN TERSM OF GLOS AND CLUSTERS.
library(Metamaps)
library(ggplot2)
library(scales)
library(data.table)
library(dplyr)
library(igraph)
library(gridExtra)
library(reshape2)
data(top500kos)
dir.create("/export2/home/uesu/sequencing_output/out/seq.0262")
load("/export2/home/uesu/sequencing_output/data/og.0701.count.rda")	#Cluster data
load("out/seq.0250.out.rda")						#GLO data	
load("data/kegg2014_top500layout.rda")					#Layout for metab graph

#'The top500 metabolic graph is generated using the new 2014 KEGG xml's. 
#+Metab-graph-KEGG14_top500, cache=TRUE
g.mRNA=grepgraph(cypherurl='192.168.100.1:7474',kos=top500kos)
#http://metamaps.scelse.nus.edu.sg:7474
V(g.mRNA)$ko.label=V(g.mRNA)$Definition
V(g.mRNA)$ko.label[grep("ko:",V(g.mRNA)$name,invert=T)]<-""

#+ Summary-of-metabolic-graphs-1, echo=TRUE
#The number of nodes in the metabolic graph
vcount(g.mRNA)	

#+ Summary-of-metabolic-graphs-2, echo=TRUE
#No. of KOs in the graph
length(grep("ko:",V(g.mRNA)$name))

#'
#newlayout=layout.fruchterman.reingold(g.mRNA)
#save(newlayout, file="data/kegg2014_top500layout.rda") 

g.mRNA$layout=newlayout
vertex.color_df=data.frame(ko=top500kos,color=colorRampPalette(c('red','orange','yellow','light green'))(length(top500kos)))
vertex.color=as.character(vertex.color_df$color[match(V(g.mRNA)$name, paste("ko:",vertex.color_df$ko,sep=""))])
vertex.color[which(is.na(vertex.color))]<-'grey'

#Raw plot#####################################################################################################
#+Raw-top500-plot, fig.cap="Metabolic partition of top500 most abundantly expressed genes,colors represent rank", fig.subcap=c("With names of KOs", "Rank colored"), fig.width=10, fig.height=10, out.width='0.6\\linewidth'
par(bg='white')
plot(g.mRNA,
    vertex.label=V(g.mRNA)$ko.label,
    vertex.size=c(1,5)[1*(1:vcount(g.mRNA) %in% grep("ko:",V(g.mRNA)$name))+1],
    vertex.label.cex=0.2,
    edge.arrow.size=0.1, 
    vertex.frame.color="#FFFFFF00"
    )

par(bg='white')
plot(g.mRNA,
    vertex.label="",
    vertex.size=c(1,5)[1*(1:vcount(g.mRNA) %in% grep("ko:",V(g.mRNA)$name))+1],
    vertex.label.cex=0.2,
    edge.arrow.size=0.1, 
    vertex.frame.color="#FFFFFF00",
    vertex.color=vertex.color
    )
#################################################################################################

#'In addition, we also investigate KO pairs from the metabolic graph of the top500 KOs (KO-cpd-KO)

#+KOPairs, cache=TRUE
pairwise=pairkos(cypherurl="192.168.100.1:7474",ko=top500kos)
pairwise=pairwise[which((pairwise[,1] %in% top500kos) * (pairwise[,2] %in% top500kos) == 1),]	

#+no.of.pairs, echo=TRUE
#No. of pairs:
nrow(pairwise)

#'Next we map the contig clusters onto the metabolic graphs
####################################################################################################
#'::Part1:: MERGING CLUSTER DATA WITH THE METABOLIC GRAPHS

#+ClusterPeak, echo=TRUE
#Preview of the data
head(data)
#+ClusterSummary, echo=TRUE
#Summary
summary(data)

#+Diveristy-Distribution
kos.in.graph=gsub("ko:","",grep("ko:", V(g.mRNA)$name, value=T))
g.ko.clusterinfo=	group_by(data) %.%
    			filter(ko %in% kos.in.graph) %.%
			arrange(desc(ncut))
g.ko.clusterinfo$ko = factor(g.ko.clusterinfo$ko, levels=as.character(g.ko.clusterinfo$ko))	#arranges the kos by their cluster size

#+ClusterDiversity_Distribution, fig.cap='Cluster size across metabolic KOs'
qplot(ko,ncut,data=g.ko.clusterinfo)+ylab("No. of Clusters")+xlab("KOs")

#+Func-to-generate-Color-gradient-legend-for-the-igraph-plots
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
	labels=colorRampPalette(c('red','orange','yellow','light green'))(length(levels(g.ko.clusterinfo$ncut_class)))
)
cluster.vertex.color=as.character(g.ko.clusterinfo$ncut_class[match(V(g.mRNA)$name, paste("ko:",g.ko.clusterinfo$ko,sep=""))])
cluster.vertex.color[is.na(cluster.vertex.color)]<-'black'

#+MetabNetworkXCluster_Diversity, fig.cap='Cluster based Diveristy Index. Color mapping onto KOs in intervals of 100, between 0,3100 from red to green'
par(bg='white')
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
par(bg='white')
color.bar(colorRampPalette(c('red','orange','yellow','light green'))(length(levels(g.ko.clusterinfo$ncut_class))),min=0,max=3100)	#declaring again for the legend
####################################################################################################


####################################################################################################
#' ::Part2:: Merging glo+genera data with metabolic graphs
metabolism=subset(diversity_index, ko %in% gsub("ko:","",grep("ko:",V(g.mRNA)$name,value=T)))
metabolism$totalglos = log10(metabolism$no.of.glos + metabolism$no.of.genera)	 

#+Summary_of_glos_genera, fig.cap='A summary of the distributions of glos, genera-classifyable and union of the former two in metabolic KOs. A log10 scale was applied on total no. of objects (glo + genera-classifiable) for mapping of colors later on.'
grid.arrange(
	qplot(metabolism$no.of.genera, geom="density"),
	qplot(metabolism$no.of.glos,geom="density"),
	qplot(metabolism$totalglos,geom="density")
	)

#Cutting the total no. of object (genera-classifiable and glos)
metabolism$totalglos_class=cut(metabolism$totalglos, 
	breaks= c(0,seq(3.5,round(mean(metabolism$totalglos)+sd(metabolism$totalglos),2), 0.05),5.2),	#included intervals
        right=TRUE, include.lowest=TRUE)
no.of.genera_legendlabels=gsub(",","-",gsub("\\[|\\]|\\(","",levels(metabolism$totalglos_class)))
metabolism$totalglos_class=factor(
	metabolism$totalglos_class, 
	levels=as.character(levels(metabolism$totalglos_class)),
	labels=colorRampPalette(c('red','orange','yellow','light green'))(length(levels(metabolism$totalglos_class)))
	)

totalglo.vertex.color=as.character(metabolism$totalglos_class[match(V(g.mRNA)$name , paste("ko:",metabolism$ko,sep=""))])
totalglo.vertex.color[is.na(totalglo.vertex.color)]<-'black'

maxlabel=as.integer(unlist(strsplit(no.of.genera_legendlabels[length(no.of.genera_legendlabels)], "-"))[2])

#+Metab-graph-with-glo_genera, fig.cap="Metabolic graph with glo data, color on a log10 scale"
par(bg='white')
layout(matrix(c(1,1,1,1,2,1,1,1,1,3), 2, 5, byrow = TRUE))
plot(g.mRNA,
    vertex.label=V(g.mRNA)$ko.label,
    vertex.size=c(1,5)[1*(1:vcount(g.mRNA) %in% grep("ko:",V(g.mRNA)$name))+1],
    vertex.color=totalglo.vertex.color,
    vertex.label.cex=0.2,
    edge.arrow.size=0.1, 
    vertex.frame.color="#FFFFFF00", 
    main="Sum total of glos_genera"
    )
par(bg='white')
color.bar(colorRampPalette(c('red','orange','yellow','light green'))(length(levels(metabolism$totalglos_class))),min=0,max=maxlabel)
####################################################################################################

#' ::Part3:: PAIRWISE COMPARISONS BETWEEN THE KOS AND DISPLAYING VIA A CLUSTERED HEATMAP
#' The raw genera occurence is not reflective of the no. of reads, hence a normalisation method gener occurence as a % of total no. of reads. Apply clustering method on the dissimlarity matrix and plot heatmap. Quite a big matrix, used GPUs.
genera_content=fread("out/seq.0262.input.txt")
koreads=setNames(summarise(group_by(glo.bigtable, ko), n()), c("KO","no.of.reads"))
new.genera_content=merge(genera_content,koreads, by="KO",all.x=T)

new.genera_content=group_by(new.genera_content, KO) %.%
mutate(norm.count = COUNT/sum(COUNT) * no.of.reads)

#+ No.of.unique.genera, echo=TRUE
length(unique(new.genera_content$GENUS))

#'
ma=acast(new.genera_content, KO~GENUS, value='norm.count',fill=0)

#+Distance, eval=FALSE, echo=TRUE
ma.dist=gpuDist(ma)

#'
load("out/seq_0262/madistance.rda")

#+Cluster, eval=FALSE, echo=TRUE
ma.clustered=gpuDistClust(ma)

#'
load("out/seq_0262/maclusted.rda")

ma.dist2=as.matrix(ma.dist)
ma.dist.melted=setNames(melt(ma.dist2), c("KO1","KO2","value"))
#ma.dist.melted=setNames(melt(ma.dist2)[melt(upper.tri(ma.dist2))$value,], c("KO1","KO2","value"))

ma.dist.melted$KO1=factor(ma.dist.melted$KO1, levels=as.character(ma.clustered$label[ma.clustered$order]))
ma.dist.melted$KO2=factor(ma.dist.melted$KO2, levels=as.character(ma.clustered$label[ma.clustered$order]))

ma.dist.melted2=rbindlist(apply(pairwise, 1, function(x) { 
	rowid=which(ma.dist.melted$KO1==x[[1]] & ma.dist.melted$KO2==x[[2]])
	ma.dist.melted[rowid,]
	}))

#+Genera-composition, fig.width=10, fig.cap="Heatmap of clusters"
ggplot(ma.dist.melted2, aes(KO1, KO2))+
geom_tile(aes(fill=value),color='white')+
scale_fill_gradient(name='Difference',low = "green",high = "red")+
theme(axis.text.x = element_text(size=2, angle = 90, hjust = 1,vjust = 0), axis.text.y = element_text(size=2))
####################################################################################################
 
#+Summary-of-differences, fig.width=10 , fig.cap="Investigating the pairwise differences in glo+genera.", fig.subcap=c("Heatmap showing pairwise difference", "Distribution of difference"), out.width='0.6\\linewidth'
diversity_index=mutate(diversity_index, total=no.of.glos+no.of.genera)
clustermap=do.call(rbind,apply(pairwise, 1, function(x) { 
	data.frame(KO1=x[[1]],KO2=x[[2]], KO2diffKO1=diff(subset(diversity_index, ko %in% x)$total))	#diff b-a
	}))
clustermap=arrange(clustermap, desc(KO2diffKO1))
qplot(x=apply(clustermap,1,function(x) paste(x[[1]],x[[2]],sep="_")) ,y=KO2diffKO1, data=clustermap, geom="point")+xlab("KO pairs")+ylab("Difference")
qplot(KO2diffKO1, data=clustermap)+xlab("Difference")

#Cluster them 
clustered1=hclust(
	#Input of hclust is a distance matrix
	d=dist(
            acast(clustermap, KO1~KO2, value="KO2diffKO1",fill=0)	
	    )
	)
clusterlabels1=clustered1$label[clustered1$order]

clustered2=hclust(
	#Input of hclust is a distance matrix
	d=dist(
            acast(clustermap, KO2~KO1, value="KO2diffKO1",fill=0)	
	    )
	)
clusterlabels2=clustered2$label[clustered2$order]

clustermap$KO1 = factor(clustermap$KO1, levels=clusterlabels1)
clustermap$KO2 = factor(clustermap$KO2, levels=clusterlabels2)
write.csv(clustermap,file="out/seq_0262/seq_0262-kopairs_glo_difference.csv")

#+GLO-difference-Heatmap, fig.cap="Pairwise comparisons"
ggplot(clustermap, aes(KO1, KO2))+
geom_tile(aes(fill=KO2diffKO1),color='white')+
scale_fill_gradient(name='Difference',low = "green",high = "red")+
theme(axis.text.x = element_text(size=2, angle = 90, hjust = 1,vjust = 0), axis.text.y = element_text(size=2))+
ggtitle("Pairwise comparison of Genera and Genera-Like object Diversity between KO pairs in Metabolic Networks")

#Cluster####################################################################################################
clustermap_xc=do.call(rbind,apply(pairwise, 1, function(x) { 
	data.frame(KO1=x[[1]],KO2=x[[2]], KO2diffKO1=diff(subset(g.ko.clusterinfo, ko %in% x)$ncut))	#diff b-a
	}))
clustermap_xc=arrange(clustermap_xc, desc(KO2diffKO1))

#+Summary-of-differences_clusters, fig.width=10 , fig.cap="Investigating the pairwise differences in clusters.", fig.subcap=c("Heatmap showing pairwise difference", "Distribution of difference"), out.width='0.6\\linewidth'
qplot(x=apply(clustermap_xc,1,function(x) paste(x[[1]],x[[2]],sep="_")) ,y=KO2diffKO1, data=clustermap_xc, geom="point")+xlab("KO pairs")+ylab("Difference")
qplot(KO2diffKO1, data=clustermap_xc)+xlab("Difference")

#Cluster them 
clustered_xc1=hclust(
	#Input of hclust is a distance matrix
	d=dist(
            acast(clustermap_xc, KO1~KO2, value="KO2diffKO1",fill=0)	
	    )
	)
clusterlabels_xc1=clustered_xc1$label[clustered_xc1$order]


clustered_xc2=hclust(
	#Input of hclust is a distance matrix
	d=dist(
            acast(clustermap_xc, KO2~KO1, value="KO2diffKO1",fill=0)	
	    )
	)
clusterlabels_xc2=clustered_xc2$label[clustered_xc2$order]

clustermap_xc$KO1 = factor(clustermap$KO1, levels=clusterlabels_xc1)
clustermap_xc$KO2 = factor(clustermap$KO2, levels=clusterlabels_xc2)
write.csv(clustermap_xc,file="out/seq_0262/seq_0262-kopairs_cluster_difference.csv")

#+Cluster-difference-Heatmap, fig.cap="Pairwise comparisons bet KOs and their cluster size differences"
ggplot(clustermap_xc, aes(KO1, KO2))+
geom_tile(aes(fill=KO2diffKO1),color='white')+
scale_fill_gradient(name='Difference',low = "green",high = "red")+
theme(axis.text.x = element_text(size=2, angle = 90, hjust = 1,vjust = 0), axis.text.y = element_text(size=2))+
ggtitle("Pairwise comparison of GLO+genera Diversity \nbetween KO pairs in Metabolic Networks")

#/* 
#Knitr options
library(knitr)
#Document wide settings
opts_knit$set(root.dir = '/export2/home/uesu/sequencing_output')

#Chunk specific settings
opts_chunk$set(echo=FALSE,warning=FALSE,error=FALSE,message=FALSE,
out.width='0.8\\linewidth',tidy=TRUE,
fig.path='out/seq_0262/seq_0262-',fig.align='center',fig.show='asis',
cache.path='markdown/seq_0262/',
cache=TRUE)

spin(hair='script/seq.0262.pairwise_sparse.r',format='Rnw',knit=FALSE)
#Add in HEADINGS
knit("script/seq.0262.pairwise_sparse.Rnw")
#*/
