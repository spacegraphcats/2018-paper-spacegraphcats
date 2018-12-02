library(GenomicRanges)
library(dplyr)
source(snakemake@input[['rhmmer']])

dom <- read_domtblout(snakemake@input[['dom']])

# read in info about gyrA seqs that matched pfam domain
dom <- makeGRangesFromDataFrame(dom,
                                keep.extra.columns=T,
                                ignore.strand=T,
                                seqinfo=NULL,
                                seqnames.field=c("domain_name"),
                                start.field="hmm_from",
                                end.field="hmm_to",
                                #strand.field="strand",
                                starts.in.df.are.0based=FALSE)

# grab matches and write out ------------------------------------


write.table(dom$query_name, file = snakemake@output[['keep']], 
              quote = F, row.names = F, col.names = F) # write sequence names to a file



