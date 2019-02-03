library(dplyr)

info <- read.csv(snakemake@input[['info']])

import_kegg <- function(file, gsub_regex, origin){
  # file name: full path to user_ko_definition.txt
  # gsub_regex: regex to use on locus_tag column to create bin identifier. For nbhds, "(_SRR1976948.[0-9_]{2,12})". For bins, "(_[0-9]*)"
  # origin: either nbhd or bin
  df <- read.csv(file, sep = "\t", stringsAsFactors = FALSE, quote = "", na.strings = "", 
                 col.names = c("locus_tag", "geneID", "name", "score", "second", "second_score")) 
  df$bin <- gsub(gsub_regex, "", df$locus_tag) # add column named bin for bin of origin
  df$origin <- rep(origin, nrow(df)) # add row specifying identity
  df <- df[df$score > 100, ] # retain only kegg ids for which the score is > 100
  return(df)
}

nbhd_df <- import_kegg(file = snakemake@input[['nbhd_kegg']], gsub_regex = "(_SRR1976948.[0-9_]{2,12})", origin = "nbhd")
bin_df <- import_kegg(file = snakemake@input[['bin_kegg']], gsub_regex = "(_[0-9]*)", origin = "bin")

bin_df <- bin_df %>% 
  filter(bin %in% nbhd_df$bin) # retain only relevant bins

# nif ---------------------------------------------------------------------

nifA <- 'K02584' #Nif-specific regulatory protein
nifB <- 'K02585' #nitrogen fixation protein NifB
nifD <- 'K02586' #nitrogenase molybdenum-iron protein alpha chain [EC:1.18.6.1]
nifE <- 'K02587' #nitrogenase molybdenum-cofactor synthesis protein NifE
nifH <- 'K02588' #nitrogenase iron protein NifH [EC:1.18.6.1]
nifHD1 <- 'K02589' #nifI1 nitrogen regulatory protein PII 1
nifHD2 <- 'K02590' #nifI2 nitrogen regulatory protein PII 2
nifK <- 'K02591' #nitrogenase molybdenum-iron protein beta chain [EC:1.18.6.1]
nifN <- 'K02592' #nitrogenase molybdenum-iron protein NifN
nifT <- 'K02593' #nitrogen fixation protein NifT
nifV <- 'K02594' #homocitrate synthase NifV [EC:2.3.3.14]
nifW <- 'K02595' #nitrogenase-stabilizing/protective protein
nifX <- 'K02596' #nitrogen fixation protein NifX
nifZ <- "K02597" # nitrogen fixation protein NifZ
glnB <- 'K04751' # nitrogen regulatory protein P-II 1
nifs <- c(nifA, nifB, nifD, nifE, nifH, nifHD1, nifHD2, nifK, nifN, nifT, nifV, nifW, nifX, nifZ, glnB)


nbhd_nifs <- nbhd_df %>%
                filter(geneID %in% nifs) %>% 
                mutate(symbol = gsub("\\;.*", "", name))

nbhd_nifs <- left_join(nbhd_nifs, info, by = c("bin" = "name")) %>%
                select(bin, taxonomy, symbol, score)

bin_nifs <- bin_df %>%
                filter(geneID %in% nifs) %>% 
                mutate(symbol = gsub("\\;.*", "", name)) %>%
                filter(bin %in% nbhd_nifs$bin)

bin_nifs <- aggregate(bin_nifs[ , 'symbol'], list(bin_nifs[ , 'bin']), function(x) toString(unique(x))) # aggregate
colnames(bin_nifs) <- c("bin", "bin_nf_genes")
nifs <- full_join(nbhd_nifs, bin_nifs, by = "bin")

write.csv(nifs, snakemake@output[['csv']], quote = FALSE, row.names = FALSE)