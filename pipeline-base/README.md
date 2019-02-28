# Pipeline to generate files needed for figures 2 and 3.

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

Look at the ``Snakefile`` for more information for what happens next!
(This is a
[snakemake workflow](https://snakemake.readthedocs.io/en/stable/);
execute `snakemake` to run it, after installing the software above.)
