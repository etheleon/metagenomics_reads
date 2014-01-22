#!/usr/bin/env Rscript
library(gridExtra)
args=commandArgs(T)

#initial exploraiton
GLO=read.table(sprintf("out/seq.0241/%s-family-GLOS",args[1]),comment.char="",fill=T,h=T)

justGLO=setNames(melt(table(GLO$GLO)), c("GLO","count"))
justGLO=justGLO[order(justGLO$count,decreasing=T),]
justGLO$glocount=sapply(justGLO$GLO, function(x) length(unlist(strsplit(as.character(x), "_")) ))
justGLO$genus=(justGLO$glocount==1)*1

#Plot1
pdf(sprintf("out/seq.0242/%s.pdf",args[1]));
ggplot(justGLO,aes(x=glocount, y=log10(count)))+
geom_point(aes(color=as.factor(genus),size = sqrt(count/pi)),alpha=0.05)+
geom_text(data=justGLO[1:10,],aes(x=glocount,y=log10(count),label=GLO,size=2))+
xlab("No. of Genera")+
ylab("No. of reads Reads (log10)")+
scale_size_continuous("Number of reads")
dev.off()

#What's missing from this the distance bet. each of the GLOs

#Need to do the edge variability


#count the occurence of that edge
#shd be able to get a distribution though how it looks like i'm really curious
#normal? or skewed?
#and the variability of the edges
