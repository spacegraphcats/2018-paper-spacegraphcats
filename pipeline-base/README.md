# Pipeline to generate files needed for figures 2-4

CTB TODO:
* make sure all config JSON files are in spacegraphcats and we cut a versioned
  release!

You'll need to [install spacegraphcats and bcalm](https://github.com/spacegraphcats/spacegraphcats/blob/master/doc/installing-spacegraphcats.md) first.

You will also need the following files & data sets:

* SRR606249.k31.abundtrim.fq.gz - Shakya et al., Podar, 2013; doi: 10.1111/1462-2920.12086; Illumina metagenome.
* SRR1976948.abundtrim.fq.gz - Hu et al., Banfield, 2016; doi: 10.1128/mBio.01669-15; sample SB1.

Download both of these short read data sets from the SRA/ENA, and process as
below to remove low-abundance k-mers, using scripts from khmer=2.1.2:

```
# both interleave-reads.py and trim-low-abund.py come from khmer==2.1.2.
interleave-reads.py ${i}_1.fastq.gz ${i}_2.fastq.gz | 
        trim-low-abund.py -C 3 -Z 18 -M 20e9 -V - -o $i.abundtrim.fq.gz
```

## figure 2

We need to build the following two directories of results:

* `podar-ref_k31_r1_search_oh0`
* `podar-ref_k31_r1_cdbg_search_oh0`

To do so, first grab the data:

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
conf/run podar-ref extract_contigs extract_reads
conf/run podar-ref search --cdbg-only
```

These should take about an hour on a reasonably fast computer, and require
under 16 GB of RAM.

## figure 3

### 3(a) - strain response curve

First, build the podarV catlas:
```
conf/run podarV build
```

Download and unpack the `podarV-strain` collection into the
`spacegraphcats` directory:

...

Then,

```
conf/run podarV-bacteroides search
conf/run podarV-denticola search
conf/run podarV-gingivalis search
```

Now collect the results:
```
```

### 3(b) - recover Fusobacterium and Proteiniclasticum.

## figure 4

* podarV_k31_r1_search_oh0
* hu-s1_k31_r1_search_oh0

```
conf/run podarV search
conf/run extract_contigs extract_reads
conf/run hu-s1 search
conf/run hu-s1 extract_contigs extract_reads
```

https://osf.io/ehgbv/ - hu genomes
