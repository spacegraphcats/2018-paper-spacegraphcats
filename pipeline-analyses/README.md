# Pipelines to generate files for figure 4(b) and various misc

This folder contains four snakemake pipelines to analyze the PLASS-assembled 
neighborhoods. These pipelines generate the content in Figures 4a and 4b, as 
well as some appendix tables and figures.

![](../paper/figures/files_dags/)

## Clustering workflow

See [this file](clustering_snakemake/README.md)
for details. The clustering workflow corresponds to the red path through the 
DAG located in the appendix.

## Variant workflow

See [this file](variant_snakemake/README.md) 
for details. The variant workflow corresponds to the yellow path through the 
DAG located in the appendix. 

## KEGG workflow & bin prokka

See [this file](kegg_snakemake/README.md) 
for details. The KEGG workflow and the bin prokka workflow correspond to the red
path through the DAG located in the appendix. 
