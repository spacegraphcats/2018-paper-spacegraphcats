## Clustering workflow
  
This folder contains the files necessary to recalculate amino acid
sequence clusters for choice PFAM domains. This analysis produces
clusters that appear in Figure 4a, the multiple sequence alignment
in Appendix Figure 5, and Appendix Tables 9-14 
(http://dx.doi.org/10.1101/462788).

To run the workflow, clone this repository, change directories into the
folder, make sure you have snakemake installed, and run snakemake.

If you have conda installed, you could run the following:

```
conda create -n hu_clustering python=3.6 snakemake=5.4.0 screed=1.0 biopython=1.72
source activate hu_clustering
cd pipeline-analyses/clustering_snakemake
snakemake --use-conda
```
