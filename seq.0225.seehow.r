#!/usr/bin/env Rscript

library(altimit)

#Task 1: Put the reads back and generate the the AUCs again
family.level=read.table("GLOs.txt", sep=" ",h=T)

#--Summary statistics
#How many family nodes 
#54

#How many GLOs are there 
#length(unique(family.level$GLO))
#99
merge(setNames(ddply(family.level, "LCA.taxid", nrow), c("LCA.taxid","GLOs")), setNames(ddply(family.level, "LCA.taxid", summarise, sum(count)), c("LCA.taxid","count")))
#The average no. of 

#Task 2: 
