#!usr/bin/env Rscript
library(Matrix)
library(biganalytics)

#Qn: how to deal with the repeation of counts ie. each row of the matrix may point to more than 1 taxa
#try with K08684

#No. of reads for each KO; ie. the no. of rows for the matrix
rowdim<-setNames(read.table("out/seq.0109a.out.txt",h=F), c("ko","rowno"))

a<-read.table(sprintf("out/seq.0107/%s/combined.output",x), h=F)
a<-a[!is.na(a$V2),] #remove na entries ie. subjects which are no longer in the genbank db
#NOTE: multiple gi no. may match to the same taxid

#Build matrix For this KO
#mm<-Matrix(0, ncol=10099, nrow=subset(rowdim, ko == x)$rowno, sparse=T)

mm1<-big.matrix(init=0, ncol=10099, nrow=subset(rowdim, ko == x)$rowno)
mm2<-big.matrix(init=0, ncol=10099, nrow=subset(rowdim, ko == x)$rowno)


#Assign values to cells in the matrix
apply(mate1, 1, function(x) { mm1[x[1], x[2]]<<-mm1[x[1], x[2]]+1 })
apply(mate2, 1, function(x) { mm2[x[1], x[2]]<<-mm2[x[1], x[2]]+1 })

#Look at the reads
#remove rows (reads) with no hits

m3<-apply(mm, 1, function(x) { 
   	#counts the no. of taxa each read hits: to ID reads which are not hitting any 
   	sum(x>0)q
	})
mm<-mm[m3>0,]

#remove cols (
#taxid and rank of columns 
load("data/taxcol.rank.rda")

#Find most referenced taxa. 
#	maxread<-apply(mm,2, sum)
#apply names to these
#head(order(maxread,decreasing=T))

m4<-apply(mm, 2, function(x) { 
   	sum(x>0) #counts the no. of reads each taxa hits
	})

#take only data corresponding to the col which have > 0 
subseteda<-a[a$colnumber %in% which(m4>0),]
mm<-mm[,m4>0]
names<-read.csv("data/tax/names.dmp.scientific2",h=F)
newsub=merge(subseteda, names, by.x="taxid",by.y="V1",all.x=T)
colnames(mm)<-newsub[order(newsub$colnumber),]$V2


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


myPalette <- brewer.pal(5, "Reds")
myBreaks <- c(0:4)
pdf("idk.pdf",w=20,h=20)
heatmap(newm,cexCol=0.2,cexRow=0.2,margins=c(10,10),col=myPalette);
legend("right", fill=myPalette, legend=c("0","1","2","3","4"))
dev.off()
#Suggestion1:most prominient taxaID::taxa hit by the most reads (careful not absolute reads) 


#OUTSTANDING match the rank to the taxID
