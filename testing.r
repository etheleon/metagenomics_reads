#!/usr/bin/env Rscript
#Translating the perl script to R #GOD FORBID

#args<-commandArgs(T)

#the reads::rows
con <- file(description="data/metab_uncl.txt", open = "r")
while(length(oneLine<-readLines(con, n=-100000, warn = F))>0) { 
for(i in 1:length(oneLines)) { 
    readID<-strsplit(oneLine[i], "\t")[[1]][[2]]
	if(!exists("a")){ a<-oneLine[i]}else{ a<-c(a,i)}
}}
close(con)



con <- file(description="data/unique.taxidlist.txt", open = "r")
while(length(oneLine<-readLines(con, n=100000, warn = F))>0) { 
	for(i in 1:length(readLines) { 

	if(!exists("b")){ b<-readID}else{ b<-c(a,readID)}
}
close(con)

