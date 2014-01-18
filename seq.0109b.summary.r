#!/usr/bin/env Rscript

summ<-read.table("summary",h=F)

pdf("out/seq.0109b.out.pdf")
qplot(V1, V2, data=summ, geom="bar")+xlab("KO")+ylab("Reads")+geom_hline(aes(yintercept=mean(summ$V2)))+ geom_hline(aes(yintercept=max(summ$V2)))
dev.off()
