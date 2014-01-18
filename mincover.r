#!/usr/bin/env Rscript
dat <- read.delim('data/sample.matrix.txt', skip = 1)
#759 reads 32 species
rownames(dat) <- dat[, 1]
dat <- dat[, -1]

dat <- as.matrix(dat)

temp <- dat
good <- c()


while(sum(temp) > 0){
    cs <- colSums(temp); 
    ma <- which.max(cs); 
    good <- c(good, colnames(temp)[ma]); 
    temp <- temp[temp[, ma] == 0, -ma] 
#temp[,ma]==0:: checks for reads which are "not satified"
#step removes rows which are already satisfied by the "no. 1 taxon" for this iteration and deletes that taxon
    }  

dat <- data.frame(dat)
#759 reads 32 species
data <- dat[, good]


save(data, file = 'output.mincover.rda')
