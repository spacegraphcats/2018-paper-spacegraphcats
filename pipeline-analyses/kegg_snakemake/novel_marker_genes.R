library(dplyr)

# read in data ------------------------------------------------------------
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

kegg_df <- rbind(nbhd_df, bin_df) # combine two dfs
kegg_df <- kegg_df %>% 
            filter(bin %in% nbhd_df$bin) # retain only relevant bins

# find marker genes ------------------------------------------------

# define nbhd marker KO
gyrA <- 'K02469'
gyrB <- 'K02470'
recA <- 'K03553'

nbhd_marker <- kegg_df %>% 
                  filter(origin == "nbhd") %>%
                  filter(geneID %in% c(gyrA, gyrB, recA))

bin_marker <- kegg_df %>% 
                filter(origin == "bin") %>%
                filter(geneID %in% c(gyrA, gyrB, recA))

# nbhd assemblies that have marker genes for which there was no ortholog in the query
novel_marks <- anti_join(unique(nbhd_marker[ , c('bin', 'name')]), unique(bin_marker[ , c('bin', 'name')]))
write.csv(novel_marks, snakemake@output[['csv']], quote = F, row.names = F)