## KEGG GhostKOALA workflow

This folder contains the files necessary to rerun the analysis of KEGG 
GhostKOALA annotations. This analysis appears in Figure 4b ( 
http://dx.doi.org/10.1101/462788). 

To run the workflow, clone this repository, change directories into the 
folder, make sure you have snakemake installed, and run snakemake. 

If you have conda installed, you could run the following:

```
conda create -n hu python=3.6
source activate hu
conda install snakemake
cd pipeline-analyses/kegg_snakemake
snakemake --use-cond
``` 

The GhostKOALA output files are downloaded as the first step in the 
workflow. To recreate these yourself, do the following:  

1. Generate the PLASS-assembled amino acid sequences for each neighborhood
using the pipeline-base Snakefile.
2. Concatenate these sequences together. 
3. Upload concatenated sequences to KEGG GhostKOALA.
4. Select "genus_prokaryotes + family_eukaryotes + viruses" database, and run KEGG
5. Download the annotation data and the taxonomy data
6. For the annotation data, click "Preview first 100", and then select "Download detail."
7. Save the file as "outputs/GhostKOALA/nbhd_user_ko_definition.txt"
8. For the taxonomy data, click download. Save the file as "outputs/GhostKOALA/nbhd.user.out.top.gz"
9. Then, unzip the file `gunzip outputs/GhostKOALA/user.out.top.gz`
10. Generate the prokka amino acid sequences for each bin using the 
pipeline-analyses/bin_prokka Snakefile. 
11. Follow steps 3-9, this time replacing `nbhd` in the filename with `bin`.  

        
