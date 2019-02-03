library(tidyr)
library(dplyr)

pidw <- read.csv(file = snakemake@input[['mat']], row.names = "X")
info <- read.csv(file = snakemake@input[['info']])

mds <- cmdscale(pidw)
mdsdf <- as.data.frame(mds)

# set mapping of names
mdsdf$query <- row.names(mdsdf)
mdsdf <- separate(mdsdf, col = query, sep = "-", into = "origin", remove = F, extra = "warn")
mdsdf$query <- gsub("BIN-", "", mdsdf$query)
mdsdf <- separate(mdsdf, col = query, sep = "_", into = "query", remove = T, extra = "warn")

mdsdf <- left_join(mdsdf, info, by = c("query" = "name"))
write.csv(mdsdf, snakemake@output[['mds']], quote = F, row.names = F)