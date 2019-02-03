library(seqinr)
library(ggtree)
library(ggplot2)
library(stringr)
library(ggthemes)

# functions ---------------------------------------------------------------

unrootedNJtree <- function(alignment, type){
  require("ape")
  require("seqinr")
  # define a function for making a tree:
  makemytree <- function(alignmentmat){
                    alignment <- ape::as.alignment(alignmentmat)
                    if(type == "protein"){
                      mydist <- dist.alignment(alignment)
                      }
                    else if(type == "DNA"){
                      alignmentbin <- as.DNAbin(alignment)
                      mydist <- dist.dna(alignmentbin)
                    }
                    mytree <- nj(mydist)
                    mytree <- makeLabel(mytree, space="") # get rid of spaces in tip names.
                    return(mytree)
                    }
  # infer a tree
  mymat  <- as.matrix.alignment(alignment)
  mytree <- makemytree(mymat)
  print("made tree!")
  # bootstrap the tree
  myboot <- boot.phylo(mytree, mymat, makemytree)
  print("calculated bootstrapped tree")
  return(mytree)
}

print("made unrootedNJtree function.")
# tree -----------------------------------------------------------------

info <- read.csv(file = snakemake@input[['info']])

aln  <- read.alignment(file = snakemake@input[['aln']], format = "fasta")

print("read info and alignment")

tree <- unrootedNJtree(aln, type = "protein")

print("made unrootedNJtree")

# MSA plot ----------------------------------------------------------------

treegg <- ggplot(tree, layout = "rectangular", branch.length = "none") + 
                geom_tree() + 
                theme_tree() + 
                geom_tiplab(size=3)
print("made tree for msa")

pal <- tableau_color_pal(palette = "Tableau 20")
max_n <- attr(pal, "max_n")
print("set palette")

# plot tree and MSA (uses mafft MSA output)
msa <- msaplot(p=treegg, fasta=snakemake@input[['aln']], 
               color = c(NA, pal(max_n)[1:20]), width = 8,  
               offset = 20)
print("made pretty MSA")
pdf(file = snakemake@output[['pdf']], height = 5, width = 11)
msa
dev.off()

