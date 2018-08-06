# Pipeline to generate files needed for figures 2-4

CTB TODO:
* make sure all config JSON files are in spacegraphcats and we cut a versioned
  release!

You'll need to [install spacegraphcats and bcalm](https://github.com/spacegraphcats/spacegraphcats/blob/master/doc/installing-spacegraphcats.md) first.

You will also need the following files & data sets:

* `SRR606249.k31.abundtrim.fq.gz` - Shakya et al., Podar, 2013; doi: 10.1111/1462-2920.12086; Illumina metagenome.
* `SRR1976948.abundtrim.fq.gz` - Hu et al., Banfield, 2016; doi: 10.1128/mBio.01669-15; sample SB1.

These are both k-mer trimmed. To generate from the raw SRA read sets,
download the raw data from the SRA/ENA, and process as below to remove
low-abundance k-mers, using scripts from khmer=2.1.2:

```
# both interleave-reads.py and trim-low-abund.py come from khmer==2.1.2.
interleave-reads.py ${i}_1.fastq.gz ${i}_2.fastq.gz | 
        trim-low-abund.py -C 3 -Z 18 -M 20e9 -V - -o $i.abundtrim.fq.gz
```

## figure 2

We need to build the following two directories of results:

* `podar-ref_k31_r1_search_oh0`
* `podar-ref_k31_r1_cdbg_search_oh0`

To do so, first grab the constituent genome data:

```
mkdir podar-ref
cd podar-ref
curl -L -o podar-reference-genomes-updated-2017.06.10.tar.gz https://osf.io/8uxj9/?action=download
tar xzf podar-reference-genomes-updated-2017.06.10.tar.gz
cd ..
```

Then, execute:

```
conf/run podar-ref search
conf/run podar-ref search --cdbg-only
```

This will build the two directories above by loading the reference
genomes into a cDBG using bcalm, generating the dominating set,
indexing the domset, and performing a number of searches. It should
take about an hour on a reasonably fast computer, and require under 16
GB of RAM.

## figure 3

### 3(a) - strain response curve

First, build the podarV catlas from the synthetic metagenome data
in Shakya et al., 2013:
```
conf/run podarV build
```

Download and unpack the `podarV-strain` collection into the
`spacegraphcats` directory:

```
curl -L -o podarV-strain.tar.gz https://osf.io/h9emb/?action=download
tar xzf podarV-strain.tar.gz
```
This will create three directories full of genomes: `bacteroides`,
 `denticola`, and `gingivalis`. Now, run searches on podarV with them:
```
conf/run podarV-bacteroides search
conf/run podarV-denticola search
conf/run podarV-gingivalis search
```

Compute the sourmash signatures for all of the strain genomes:
```
for i in denticola gingivalis bacteroides
do
   cd $i
   sourmash compute -k 31 --scaled=1000 --name-from-first *.gz
   cd ..
done
```

Same for podar-ref:
```
cd podar-ref
sourmash compute -k 31 --scaled=1000 --name-from-first ?.fa ??.fa
cd ../
```

Now, do the computation:

```
sourmash search podar-ref/56.fa.sig denticola/*.sig -n 0 --threshold=0.0 -o denticola.csv
sourmash search podar-ref/37.fa.sig gingivalis/*.sig -n 0 --threshold=0.0 -o gingivalis.csv
sourmash search podar-ref/4.fa.sig bacteroides/*.sig -n 0 --threshold=0.0 -o bacteroides.csv 

# ---

cd podarV_k31_r1_search_oh0_bacteroides
for i in GCA*.sig; do sourmash search ../podar-ref/4.fa.sig $i -o $i.sim.csv --threshold=0.0 -n 0; done
for i in GCA*.sig; do sourmash search ../podar-ref/4.fa.sig $i -o $i.cont.csv --threshold=0.0 -n 0 --containment; done

head -1 GCA_900104585.1_PRJEB16348_genomic.fna.gz.contigs.sig.sim.csv > bacteroides.x.contigs.sim.csv
for i in GCA*.sim.csv; do tail -1 $i; done >> bacteroides.x.contigs.sim.csv

head -1 GCA_900104585.1_PRJEB16348_genomic.fna.gz.contigs.sig.cont.csv > bacteroides.x.contigs.cont.csv
for i in GCA*.cont.csv; do tail -1 $i; done >> bacteroides.x.contigs.cont.csv

cd ../

# ----

cd podarV_k31_r1_search_oh0_gingivalis

for i in GCA*.sig; do sourmash search ../podar-ref/37.fa.sig $i -o $i.sim.csv --threshold=0.0 -n 0; done
for i in GCA*.sig; do sourmash search ../podar-ref/37.fa.sig $i -o $i.cont.csv --threshold=0.0 -n 0 --containment; done

head -1 GCA_900157325.1_3A1_genomic.fna.gz.contigs.sig.sim.csv > gingivalis.x.contigs.sim.csv
for i in GCA*.sim.csv; do tail -1 $i; done >> gingivalis.x.contigs.sim.csv

head -1 GCA_900157325.1_3A1_genomic.fna.gz.contigs.sig.cont.csv > gingivalis.x.contigs.cont.csv
for i in GCA*.cont.csv; do tail -1 $i; done >> gingivalis.x.contigs.cont.csv

cd ../

# ---

cd podarV_k31_r1_search_oh0_denticola

for i in GCA*.sig; do sourmash search ../podar-ref/56.fa.sig $i -o $i.sim.csv --threshold=0.0 -n 0; done
for i in GCA*.sig; do sourmash search ../podar-ref/56.fa.sig $i -o $i.cont.csv --threshold=0.0 -n 0 --containment; done

head -1 GCA_900164975.1_16852_2_85_genomic.fna.gz.contigs.sig.sim.csv > denticola.x.contigs.sim.csv
for i in GCA*.sim.csv; do tail -1 $i; done >> denticola.x.contigs.sim.csv

head -1 GCA_900164975.1_16852_2_85_genomic.fna.gz.contigs.sig.cont.csv > denticola.x.contigs.cont.csv
for i in GCA*.cont.csv; do tail -1 $i; done >> denticola.x.contigs.cont.csv

cd ../

```

### 3(b) - recover Fusobacterium and Proteiniclasticum from podarV.

```
curl -o podarV-recover.tar.gz -L https://osf.io/w3xuf/?action=download
tar xzf podarV-recover.tar.gz
```
This creates subdirectories `ruminis` and `fuso`.  The former contains
all *Proteiniclasticum ruminis* genomes from GenBank, and the latter
contains the 8 *Fusobacterium* strains detected in the read data set
using `sourmash gather`.

Now, do the first round retrieval of neighborhoods:

```
conf/run podarV-fuso search
conf/run podarV-ruminis search
```

which will produce the directories `podarV_k31_r1_search_oh0_fuso` and
`podarV_k31_r1_search_oh0_ruminis`.

Next, extract the reads corresponding to each neighborhood:

```
gunzip -c podarV_k31_r1_search_oh0_ruminis/*.cdbg_ids.txt.gz | gzip -9c > ruminis-combined-node-list.txt.gz
python -m spacegraphcats.search.extract_reads podarV/podarV.reads.bgz podarV_k31_r1/reads.bgz.labels ruminis-combined-node-list.txt.gz -o ruminis.reads.fa

gunzip -c podarV_k31_r1_search_oh0_fuso/*.cdbg_ids.txt.gz | gzip -9c > fuso-combined-node-list.txt.gz
python -m spacegraphcats.search.extract_reads podarV/podarV.reads.bgz podarV_k31_r1/reads.bgz.labels fuso-combined-node-list.txt.gz -o fuso.reads.fa
```

Assemble the reads using megahit:

```
conda install -y megahit
megahit -r ruminis.reads.fa -o ruminis.assembly
megahit -r fuso.reads.fa -o fuso.assembly
```

Check completeness with checkm:
```
conda create -n py27 python=2.7 anaconda checkm-genome
conda activate py27
mkdir bins

cp ruminis.assembly/final.contigs.fa bins/P_ruminis_shakya.fa
cp fuso.assembly/final.contigs.fa bins/Fuso_spp_shakya.fa

checkm lineage_wf -x fa --reduced_tree bins out
```

& done!

## Figure 4

### Figure 4(a), neighborhood sizes for podar-ref, podarV, and hu-s1

We need the following output directories:

* `podarV_k31_r1_search_oh0`
* `hu-s1_k31_r1_search_oh0`

First, generate the primary results:
```
conf/run podarV search extract_contigs extract_reads
conf/run hu-s1 search extract_contigs extract_reads
```

You'll also want the hu-genomes:

```
mkdir hu-genomes
cd hu-genomes
curl -L -o hu-genomes.tar.gz https://osf.io/ehgbv/?action=download
tar xzf hu-genomes
.tar.gz
cd ../
```
