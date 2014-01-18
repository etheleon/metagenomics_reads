#!/usr/bin/env Rscript
library(igraph)
path=read.csv("out/seq.0118/K01915-family-126-ex3.txt")

the.nodes=sort(unique(c(unlist(lapply(as.character(path$Path), function(x) { strsplit(x,"_") })))))

#Adjacency matrix
M=matrix(0,ncol=length(the.nodes), nrow=length(the.nodes))
colnames(M)=the.nodes
rownames(M)=the.nodes


apply(path, 1, function(x) { 

#lapply(as.character(path$Path), function(x) { 

	pathh=unlist(strsplit(x[2], "_"))
	for(i in 1:length(pathh)-1){ 
	M[which(rownames(M) == pathh[i+1]), which(colnames(M) == pathh[i])]<<-x[3]
	M[which(rownames(M) == pathh[i]), which(colnames(M) == pathh[i+1])]<<-x[3]
	}
	})

g<-graph.adjacency(M, mode="undirected",weighted=T)	

root=unlist(strsplit(as.character(path$Path[1]), "_"))[1]
root=which(V(g)$name==root)

#--Plot
pdf("testing.pdf");
plot(g, layout = layout.reingold.tilford(g, root=root), edge.width=E(g)$weight)
dev.off()

combination of paths
ie. 
read1 - path1 path2 

