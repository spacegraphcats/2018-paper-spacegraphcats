## Variant workflow
  
This folder contains the files necessary to visualize variants in 
nucleotide sequences that code for amino acid sequence variants for 
choice PFAM domains. This analysis produces the .gfa files used to
make the assembly graphs that appear in Figure 4a 
(http://dx.doi.org/10.1101/462788).

To run the workflow, clone this repository, change directories into the
folder, make sure you have snakemake installed, and run snakemake.

If you have conda installed, you could run the following:

```
conda create -n hu_variant python=3.6 snakemake=5.4.0 pysam=0.15.2
source activate hu_variant
cd pipeline-analyses/variant_snakemake
snakemake --use-conda
```

