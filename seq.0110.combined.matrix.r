#!usr/bin/env Rscript
library(RColorBrewer)
library(Matrix)
library(biganalytics)
load("data/taxcol.rank.rda")
####NOTE: multiple gi no. may match to the same taxid ####


#Qn: how to deal with the repeation of counts ie. each row of the matrix may point to more than 1 taxa
#try with K08684

#No. of reads for each KO; ie. the no. of rows for the matrix
rowdim<-setNames(read.table("out/seq.0109a.out.txt",h=F), c("ko","rowno"))

#a<-read.table(sprintf("out/seq.0107/%s/combined.output",x), h=F)

#remove na entries ie. subjects (gi|xxxxxxx) which are no longer in the genbank db
a<-a[!is.na(a$V2),] 

#Build matrix For this KO
#mm<-Matrix(0, ncol=10099, nrow=subset(rowdim, ko == x)$rowno, sparse=T)
#For mate pair1 and mate pair2
mm1<-big.matrix(init=0, ncol=10099, nrow=subset(rowdim, ko == x)$rowno)
mm2<-big.matrix(init=0, ncol=10099, nrow=subset(rowdim, ko == x)$rowno)

#Assign values to cells in the matrix
apply(mate1, 1, function(x) { mm1[x[1], x[2]]<<-mm1[x[1], x[2]]+1 })
apply(mate2, 1, function(x) { mm2[x[1], x[2]]<<-mm2[x[1], x[2]]+1 })

#Look at the reads
#remove rows (reads) with no hits & cols (taxa with no hits)

#-- find empty rows and cols; not all reads are captured with that run.
m3<-apply(mm1, 1, function(x) { sum(x>0) })
m3.2<-apply(mm2, 1, function(x) { sum(x>0) })
#-- the rows to be kept for both matrices
m3<-unique(c(which(m3>0), which(m3.2>0)))

#-- Finds empty col (taxa)
m4<-apply(mm1, 2, function(x) { sum(x>0) })
m4.2<-apply(mm2, 2, function(x) { sum(x>0) })

#The columns to be kept
taxa.to.be.kept=unique(c(which(m4>0), which(m4.2>0)))

mm1<-mm1[m3,]
mm2<-mm2[m3,]
subseteda<-taxcolrank[taxcolrank$colnumber %in% taxa.to.be.kept,]
mm1<-mm1[,taxa.to.be.kept]
mm2<-mm2[,taxa.to.be.kept]

#take only data corresponding to the col which have > 0 
names<-read.csv("data/tax/names.dmp.scientific2",h=F)
newsub=merge(subseteda, names, by.x="taxid",by.y="V1",all.x=T)
colnames(mm1)<-newsub[order(newsub$colnumber),]$V2
colnames(mm2)<-newsub[order(newsub$colnumber),]$V2

newm1=as.matrix(mm1)
newm2=as.matrix(mm2)

dir.create("out/pdf/seq.0110.out");

#--Mate1
myPalette <- brewer.pal(7, "Reds")
myBreaks <- c(0:7)

pdf("idk_testing.pdf",w=20,h=20)
heatmap(newm1,cexCol=0.8,cexRow=0.2,margins=c(17,17),col=myPalette);
legend("right", fill=myPalette, legend=c(0:7))
dev.off()

flat.data1=data.frame(taxa=colnames(newm1),count=apply(newm1, 2, sum))
rownames(flat.data1)<-NULL

#we could run the a circos plot. each node will be 1 taxa and the links are the reads

myPalette <- brewer.pal(6, "Blues")
myBreaks <- c(0:6)

pdf("idk_testing2.pdf",w=20,h=20)
heatmap(newm2,cexCol=0.8,cexRow=0.2,margins=c(17,17),col=myPalette);
legend("right", fill=myPalette, legend=c(0:6))
dev.off()

#Suggestion1:most prominient taxaID::taxa hit by the most reads (careful not absolute reads) 












#Run kmeans
seehow<-kmeans(x=mm, centers=10)

#Plot reads X taxid
newm=as.matrix(mm)

b<-dist(newm,diag=T)
g<-hclust(b)

#Distrance df
m <- data.frame(t(combn(1:nrow(newm),2)), as.numeric(b))
names(m) <- c("c1", "c2", "value")

myPalette <- colorRampPalette(rev(brewer.pal(11, "Spectral")))
values <- seq(0, max(m$distance), length = 11)

zp1 <- ggplot(m,aes(x = c1, y = c2, fill = value))
zp1 <- zp1 + geom_tile()
zp1 <- zp1 + scale_fill_gradientn(colours = myPalette(100),values = values, rescaler = function(x, ...) x, oob = identity)
zp1 <- zp1 + scale_x_discrete(limits=g$order,expand = c(0, 0))
zp1 <- zp1 + scale_y_discrete(limits=g$order,expand = c(0, 0))
zp1 <- zp1 + coord_equal()
zp1 <- zp1 + theme_bw()


pdf("out/idk.heat.map.pdf")
print(zp1)
dev.off()
#which taxa are contributing most to these 



#OUTSTANDING match the rank to the taxID
