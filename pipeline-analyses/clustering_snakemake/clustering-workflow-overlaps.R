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

# define reads to keep for pid calc ------------------------------------

if(max(dom$domain_len) > 211){
  # if the domain is greater than 211 residues:
  # make a sliding window of 200bp that progresses by 10 bp each step. 
  # Calc overlaps for each of these. 
  # Select the one that is longest at the end. 
  ranges <- seq(from = 1, to = (max(dom$domain_len) - 200), by = 10)
  all <- list()

  for(start in ranges){
    end = start + 200
    want <- makeGRangesFromDataFrame(data.frame(domain_name = as.character(seqnames(dom))[1], 
                                                start = start, end = end), 
                                     keep.extra.columns=T,
                                     ignore.strand=T,
                                     seqinfo=NULL,
                                     seqnames.field=c("domain_name"),
                                     start.field="start",
                                     end.field="end",
                                     #strand.field="strand",
                                     starts.in.df.are.0based=FALSE)
    ov <- subsetByOverlaps(dom, want, minoverlap = 125)
    all[[length(all)+1]] <- ov
  }
  most <- which.max(sapply(all, length)) # find the granges object with the most records
  print(paste0("200 aa region with most overlapping seqs starts at residue ", ranges[most]))
  write.table(all[[most]]$query_name, file = snakemake@output[['keep']], 
              quote = F, row.names = F, col.names = F) # write sequence names to a file
} else {
  # if the domain is not greater than 211 bp:
  # subset to aa seqs that overlap at least half of the in the domain
  start = 1
  end = length(dom)
  want <- makeGRangesFromDataFrame(data.frame(domain_name = as.character(seqnames(dom))[1], 
                                              start = start, end = end), 
                                   keep.extra.columns=T,
                                   ignore.strand=T,
                                   seqinfo=NULL,
                                   seqnames.field=c("domain_name"),
                                   start.field="start",
                                   end.field="end",
                                   #strand.field="strand",
                                   starts.in.df.are.0based=FALSE)
  ov <- subsetByOverlaps(dom, want, minoverlap = (length(dom)/2))
  print("Domain not long enough to select area with most coverage. 
        Used whole domain, kept sequences that overlapped at least half of domain.")
  write.table(ov$query_name, file = snakemake@output[['keep']], 
              quote = F, row.names = F, col.names = F) # write sequence names to a file
}


