# Code for calculating Plass assembly containment in nt assemblies

Below is the code used to calculate the 19.6% number for plass proteins
in the nucleotide assemblies of the hu extracted genomes.

## in bash:

```
# started from plass hardtrim, delivered by titus via aws
  
cd plass-hardtrim
for infile in *fa
do
  awk '/>/{sub(">","&"FILENAME"_");sub(/\.hardtrim.plass.c100.fa/,x)}1' $infile > ${infile}.clean
done


# hand separated into sb1 and sb2 files

# make file headers unique
cd hu-genomes-plass/sb1
for infile in *clean
do
  cut -d ' ' -f1 $infile > ${infile}.cut
done

for infile in *cut
do
  awk '(/^>/ && s[$0]++){$0=$0"_"s[$0]}1;' $infile > ${infile}.dup
done

# linked in hu-bin prokka 

cd ..
for infile in hu-bins/*faa
do
    j=$(basename $infile .faa)
    blastp -query plass-hardtrim/${j}.hardtrim.plass.c100.fa.clean.cut.dup -subject ${infile} -outfmt 6 -out ${j}.tab
done
```

## In R

```
# Read PLASS assemblies into R with Biostrings to get the correct count of the number of amino acids in the assembly.

library(Biostrings)
library(dplyr)

nbhds <- list.files("explore/blast_plass_bin/plass-hardtrim", ".dup$", full.names = T)
nbhd_names <- list.files("explore/blast_plass_bin/plass-hardtrim", ".dup$")
nbhds <- lapply(nbhds, readAAStringSet) # import the plass nbhds
nbhd_aas <- sapply(nbhds, length) # get the number of AAs in each nbhd

blast <- list.files("explore/blast_plass_bin/", ".tab$", full.names = T) 
blast <- lapply(blast, read.table) # import blast

tmp <- data.frame()
df <- data.frame()
for(i in 1:length(blast)){
  tmp <- blast[[i]] %>%
          filter(V3 == 100) # retain only AAs that were 100% 
  tmp_length <- length(unique(tmp$V1))  # count num aas 100% contained
  # XX prots in PLASS are 100% contained in the bin prots
  df[i, 'plass_in_bin'] <- tmp_length
  df[i, 'bin'] <- nbhd_aas[i]
  df[i, 'name'] <- nbhd_names[i]
}


df$f_plass_100_contained_in_bin <- df$plass_in_bin / df$bin # calc percent for each
sum(df$f_plass_100_contained_in_bin)/23 # calc average
```
