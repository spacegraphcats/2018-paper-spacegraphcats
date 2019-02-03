# the purpose of this script is to visualize the number of unique annotations 
# originating from the bins and from the plass assembled protein seq. 

library(dplyr)
library(ggplot2)
library(tidyr)

# READ & FORMAT DATA ------------------------------------------------------------
import_kegg <- function(file, gsub_regex, origin){
  # file name: full path to user_ko_definition.txt
  # gsub_regex: regex to use on locus_tag column to create bin identifier. 
  #             For plass, "(_SRR1976948.[0-9_]{2,12})". For bins, "(_[0-9]*)"
  # origin: either plass or bin
  df <- read.csv(file, sep = "\t", stringsAsFactors = FALSE, quote = "", na.strings = "", 
                 col.names = c("locus_tag", "geneID", "name", "score", "second", "second_score")) 
  df$bin <- gsub(gsub_regex, "", df$locus_tag) # add column named bin for bin of origin
  df$origin <- rep(origin, nrow(df)) # add row specifying identity
  df <- df[df$score > 100, ] # retain only kegg ids for which the score is > 100
  return(df)
}

info <- read.csv(snakemake@input[["info"]]) # read in metadata
#info <- read.csv("inputs/hu_info.csv")
info <- info %>% 
          filter(sample_origin == "SB1") # only keep SB1 samples

plass_df <- import_kegg(file = snakemake@input[["plass_kegg"]], 
                        gsub_regex = "(_SRR1976948.[0-9_]{2,12})", origin = "plass")

# plass_df <- import_kegg(file = "outputs/GhostKOALA/user_ko_definition.txt", gsub_regex = "(_SRR1976948.[0-9_]{2,12})", origin = "plass")
plass_df <- plass_df %>% 
              filter(bin %in% info$name) # filter to SB1 samples

bin_df <- import_kegg(snakemake@input[["bin_kegg"]], 
                      gsub_regex = "(_[0-9]*)", origin = "bin")
# bin_df <- import_kegg(file = "outputs/hu-bins/GhostKOALA/user_ko_definition.txt", gsub_regex = "(_[0-9]*)", origin = "bin")
kegg_df <- rbind(plass_df, bin_df) # combine two dfs

kegg_df <- kegg_df %>%
            filter(bin %in% plass_df$bin) # filter out the extra hu bins

# grab unique KOs per bin --------------------------------

# bin
unique_bin <- function(kegg_df, Bin){
                hu <- kegg_df %>% filter(bin == Bin) # filter to bin of interest
                hu_bin <- hu %>% filter(origin == "bin") # filter to hu bins
                uni <- unique(hu_bin$geneID) # take unique (i.e. remove dups), get num of unique
                df <- data.frame("geneID" = uni, "bin" = rep(Bin, length(uni)), "origin" = rep("bin", length(uni)))
                return(df)
              }

# plass
unique_plass <- function(kegg_df, Bin){
                  hu <- kegg_df %>% filter(bin == Bin)
                  hu_plass <- hu %>% filter(origin == "plass") # subset out plass
                  hu_bin <- hu %>% filter(origin == "bin") # subset out bin
                  uni <- hu_plass[!(hu_plass$geneID %in% hu_bin$geneID), ] # get KOs in plass that do not occur in bin
                  uni <- unique(uni$geneID) # take "unique" of these KOs (i.e. remove dups), return num
                  df <- data.frame("geneID" = uni, "bin" = rep(Bin, length(uni)), "origin" = rep("plass", length(uni)))
                  return(df)
                }

uni_plass <- lapply(unique(info$name), function(x) unique_plass(kegg_df = kegg_df, Bin = x))
uni_bin <- lapply(unique(info$name), function(x) unique_bin(kegg_df = kegg_df, Bin = x))
uni_plass <- do.call(rbind, uni_plass)
uni_bin <- do.call(rbind, uni_bin)

uni <- rbind(uni_plass, uni_bin)

# DO KEGG -----------------------------------------------

keggparse <- read.delim(snakemake@input[['kegg']], header= F, sep = "\t")
# keggparse <- read.delim("inputs/ko00001_parse.txt", header= F, sep = "\t")
keggparse <- separate(keggparse, V4, into = c("geneID", "description"), sep = " ", remove= T, extra = "merge", fill = "left")
keggparse <- separate(keggparse, V3, into = c("path", "num"), sep = "\\[", remove = T, extra = "merge", file = "left")
keggparse <- separate(keggparse, path, into = c("num2", "path"), sep = " ", remove = T, extra = "merge", file = "left")
keggparse <- separate(keggparse, V2, into = c("num3", "category"), sep = " ", remove = T, extra = "merge", file = "left")

# deal with duplicates -- there are only 22,236 kegg orthologs in keggparse, but there are 49,935 rows, meaning there are duplicates. 
# the solution below is a hack; I haven't come up wtih a better way to deal with it
keggparse <- keggparse[match(unique(keggparse$geneID), keggparse$geneID), ]

# change the name of "Enzymes with EC numbers" to uncategorized
keggparse$path <- gsub("Enzymes with EC numbers", "Uncategorized", keggparse$path)


# hu_content_b -------------------------------------------------------

# Transfer mappings to original kegg data
map <- left_join(uni, keggparse, by = "geneID")

sum_df <- map %>%
            group_by(path) %>%
            tally() # tally the description; use to set order of the plot

sum_df <- sum_df[order(sum_df$n, decreasing = T), ] # order by total occurence
sum_df <- sum_df[1:20, ] # retain only top 20
#sum_df$path <- droplevels(sum_df$path)
sum_df$path <- factor(sum_df$path, 
                             levels = sum_df$path[order(sum_df$n)]) # set order from overall sums

map <- filter(map, path %in% sum_df$path) # prune map to only top 20

# Use the order set above to set order of factor levels in mapped data
map$path <- factor(map$path, levels = sum_df$path[order(sum_df$n)])

# set colors to Felix's scheme
steel_blue       = "#3e80b8ff" 
selective_yellow = "#ffb500ff" # Excavator yellow
viridian         = "#4b9179ff" # Green with a hint of blue
white_rock       = "#f1ece0ff" # Lighter off-white
rose             = "#ff1164ff"
fuscous_gray     = "#5c594fff" # Darkish gray
hot_pink         = "#ff70b0ff"

hu_content_b <- ggplot(map, aes(x = path, fill = origin, width = 1)) + 
                  geom_bar(show.legend = F) + 
                  geom_point(aes(x = path, y = 1, fill = origin, color = origin)) +
                  scale_y_continuous(limits = c(0, 800), expand = c(0, 0)) +
                  theme_minimal() +
                  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 10),
                        axis.title.y=element_blank(), 
                        axis.text.y = element_text(size = 10),
                        panel.border = element_blank(), 
                        panel.background = element_rect(fill= white_rock , colour= white_rock),
                        panel.grid.major = element_blank(),
                        panel.grid.minor = element_blank(), 
                        axis.line = element_line(colour = white_rock),
                        legend.position="bottom",
                        legend.title = element_text(face="bold")) +
                  coord_flip()  +
                  scale_color_manual(values = c(hot_pink, fuscous_gray), 
                                     labels = c("unbinned content", "all binned genomes")) +
                  scale_fill_manual(values = c(hot_pink, fuscous_gray), 
                                    labels = c("unbinned content", "all binned genomes")) +
                  guides(color = guide_legend(override.aes = list(size = 7)))


# write plot
pdf(snakemake@output[["pdf"]], width = 6.2, height = 5.5)
hu_content_b
dev.off()

png(snakemake@output[["png"]], width = 6.2, height = 5.5, units = 'in', res = 300)
hu_content_b
dev.off()



