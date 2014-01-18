#!/usr/bin/env Rscript

library(gridExtra)
args=commandArgs(T) #the KO and the 

load("../abu_genes/data/ko.name.rda")
koname=subset(ko.name, ko == args[1])$name

input=paste("./out/seq.0118/",args[1],"-ex2.txt",sep="")
dir.create("./out/seq.0118/cluster")

#binary=read.table("/dev/stdin", h=F,comment.char="",colClasses=c("character","character","factor"));

binary=read.table(input, h=F,comment.char="",colClasses=c("character","character","factor"),skip=1);
colnames(binary)=c('readID','binary','classified');

temp=as.matrix(do.call(rbind,strsplit(binary$binary, "")))
class(temp)<-"integer"

#All together
binary2=data.frame(binary[,-2],setNames(as.data.frame(temp), unlist(strsplit(readLines(file(input),n=1),"\\t"))))
ll=hclust(dist(temp, method="binary"))$order
binary.all=binary2[ll,]

#new.binary.all=setNames(as.data.frame(t(
#apply(binary.all,1, function(x) {
#    if(x[[2]]=='classifiable'){
#    	as.integer(x[-c(1:2)])*2
#    	}else{
#    	    as.integer(x[-c(1:2)])
#    	    }
#})
#)), unlist(strsplit(readLines(file("out/seq.0118/K11903-ex2.txt"),n=1),"\\t")))
#
#new.binary.all$no=1:nrow(binary.all)
#binary3<-new.binary.all#removes the read ID
#binary3$no=factor(binary3$no)
#binary3=melt(binary3, id=c("no"))
#binary3$value=as.factor(binary3$value)

#Cluster again? 
newcluster=t(apply(binary.all,1, function(x) {
    if(x[[2]]=='classifiable'){
    	as.integer(x[-c(1:2)])*2
    	}else{
    	    as.integer(x[-c(1:2)])
    	    }
}))
new.binary2=setNames(as.data.frame(newcluster), unlist(strsplit(readLines(file("out/seq.0118/K11903-ex2.txt"),n=1),"\\t")))

new.binary2=new.binary2[hclust(dist(newcluster))$order,]
new.binary2$no=1:nrow(new.binary2)

binary6<-new.binary2#removes the read ID
binary6$no=factor(binary6$no)
binary6=melt(binary6, id="no")
binary6$value=as.factor(binary6$value)


#Separate
##Classified
binary.cl=subset(binary2, classified=="classifiable")
ll=hclust(dist(binary.cl[,!names(binary.cl) %in% c("readID","classified")],method="binary"))$order
binary.cl=binary.cl[ll,]
binary.cl$no<-1:nrow(binary.cl)

binary4<-binary.cl[,-1] #removes the read ID
binary4$no=factor(binary4$no)
binary4=melt(binary4, id=c("no", "classified"))
binary4$value=as.factor(binary4$value)


##Unclassified
binary.ucl=subset(binary2, classified=="unclassifiable")
ll=hclust(dist(binary.ucl[,!names(binary.ucl) %in% c("readID","classified")],method="binary"))$order
binary.ucl=binary.ucl[ll,]
binary.ucl$no<-1:nrow(binary.ucl)

binary5<-binary.ucl[,-1] #removes the read ID
binary5$no=factor(binary5$no)
binary5=melt(binary5, id=c("no", "classified"))
binary5$value=as.factor(binary5$value)

#--plot::Facet
#multicolor
#p1=ggplot(binary3, aes(no, variable))+geom_tile(aes(fill=value),color=NA)+#theme_blank()+
#theme(axis.ticks = element_blank(), axis.text.x = element_blank(), panel.grid.major=element_blank(), panel.grid.minor=element_blank())+xlab("Reads")+ylab("Genus")+
#scale_fill_manual(values=c("white","#FF000030","#377EB8"))

p1=ggplot(binary6, aes(no, variable))+geom_tile(aes(fill=value),color=NA)+#theme_blank()+
theme(axis.ticks = element_blank(), axis.text.x = element_blank(), panel.grid.major=element_blank(), panel.grid.minor=element_blank())+xlab("Reads")+ylab("Genus")+
scale_fill_manual(values=c("white","#FF0000","#377EB8"),labels=c("0","Unclassifiable Reads","Classifiable Reads"))+
ggtitle(paste("Total number of mate 1 and 2 reads: ", nrow(binary6)))

p2=ggplot(binary4, aes(no, variable))+geom_tile(aes(fill=value))+#theme_blank()+
theme(axis.title.x=element_blank(),axis.title.y=element_blank() ,axis.ticks = element_blank(), legend.position="none", axis.text.x = element_blank(), axis.text.y = element_blank(),panel.grid.major=element_blank(), panel.grid.minor=element_blank())+xlab("Reads")+ylab("Genus")+
scale_fill_manual(values=c("white","#377EB8"))+ggtitle(paste("Classifiable reads: ",nrow(binary4)))

p3=ggplot(binary5, aes(no, variable))+geom_tile(aes(fill=value))+#theme_blank()+
theme(axis.ticks = element_blank(), axis.title.y=element_blank(), axis.text.x = element_blank(), legend.position="none", axis.text.y=element_blank(), panel.grid.major=element_blank(), panel.grid.minor=element_blank())+xlab("Reads")+ylab("Genus")+
scale_fill_manual(values=c("white","#FF0000"))+ggtitle(paste("Unclassifiable reads: ",nrow(binary5)))

pdf(paste("out/seq.0118/cluster/",args[1],".pdf",sep=""),w=15)
grid.arrange(p1,arrangeGrob(p2,p3, nrow=2),nrow=1,widths=c(2,1),main=textGrob(paste("KO: ",args[1], " ", koname,  sep="" ), gp=gpar(fontsize=20,font=3)))
dev.off()

#hamming.distance(temp)
