library(Biostrings)
library(stringr)
cdh <- readAAStringSet(snakemake@input[['cdh']])
info <- read.csv(snakemake@input[['info']])

name <- names(cdh)
name <- gsub("_.*", "", name)
name <- as.data.frame(name)
name <- separate(name, col = name, into = c("origin", "name"), sep = -11)
name <- left_join(name, info)
name <- paste0(name$origin, name$abbreviation)
name <- gsub("BIN-", "Bin-", name)
name <- trimws(name, which = "right")
name <- gsub(" ", "-", name)

names(cdh) <- name
writeXStringSet(cdh, snakemake@output[['named']])
