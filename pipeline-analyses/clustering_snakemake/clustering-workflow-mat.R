library(tidyr)

# read in data and format as a matrix

pid <- read.table(file = snakemake@input[['pid']], skip = 1, header = F)
colnames(pid) <- c('seqname1', 'seqname2', 'pid', 'nid', 'denomid', 'pmatch', 'nmatch', 'denommatch')
pid$alipid <- pid$nid / pid$nmatch # calculate percent identity only over length of sequence where two sequences overlapped
pid$alipid <- 1-pid$alipid # change into distance, instead of similarity
pid2 <- pid[ , c('seqname1', 'seqname2', 'alipid')] # select relevant columns

dummy1 <- data.frame(seqname1 = pid2$seqname2, seqname2 = pid2$seqname1, alipid = pid2$alipid) # make sure all combinations are represented
dummy2 <- data.frame(seqname1 = unique(pid2$seqname1), 
                     seqname2 = unique(pid2$seqname1), 
                     alipid = rep(0, length(unique(pid2$seqname1)))) # add in self comp for diag of matrix

pid2 <- rbind(pid2, dummy1, dummy2) # make one df

pidw <- spread(pid2, key = seqname2, value = alipid, drop = F) # transform from long to square
row.names(pidw) <- pidw[ , 'seqname1'] # set rownames 
pidw <- pidw[ , -1] # remove text
pidw <- as.matrix(pidw) # convert to matrix
pidw[is.na(pidw)] <- 1 # set NAs, which mean no bp overlapped between two sequences, to 1. 

write.csv(pidw, file = snakemake@output[['mat']])