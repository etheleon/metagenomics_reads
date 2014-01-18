#!/usr/bin/env Rscript

args<-commandArgs(T)
#args will have path to folder

files = paste(args[1],list.files(path=args[1]),sep="")

#the row and column names
roww<-read.table("data/top.expressed_metabkos.txt")
coll<-read.table("data/top.expressed_metabkos.txt")

zero<-read.table(file="out/seq.0104/b2-0058_s_3.1.m8.bz2.output", sep=" ",h=F)
zero<-matrix(0, nrow=nrow(zero), ncol=ncol(zero))

for (i in files){ 
alpha<-read.table(file=i,h=F)
zero<<-zero+alpha
} 
colnames(zero)<-coll$V1
rownames(zero)<-roww$V1

write.table(zero, file=sprintf("%s.combined.txt",args[1]), row.names=T, col.names=T)

