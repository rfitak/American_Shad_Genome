# Raw Sequencing Read Cleaning
This section will start with the raw sequencing data and perform a series a cleaning steps to prepare the sequences for the genome assembly.  The various steps include:
1.  Filtering low-quality reads, Trimming low-quality bases, adapter identification and removal
    - Program: [Fastp](https://github.com/OpenGene/fastp)
2.  Removing identical read pairs
    - Program: [FastUniq](https://sourceforge.net/projects/fastuniq/)
3.  Removing Mate-pair reads that overlap
    - Program: [Fastq-join](https://github.com/brwnj/fastq-join)
4.  Removing reads that map conclusively to the American Shad mitochondrial genome
    - A mitgenome is already available, so we want to minimize their presence
5.  Kmer counting and Error-correcting the sequencing reads
    - Program: Undecided (Dsk, Quake, Musket, BFC...)

### Raw Data Summary:
| Read Set | Type | Insert Size | \# Paired Reads | \# Bases |
| --- | --- | --- | --- | --- |
| Short Insert | 151 bp; Paired-end | TBD | 313,465,270 | 94,666,511,540 |
| Long Insert | 151 bp; Mate-pair | 5-7 kb | 226,692,460 | 68,461,122,920 |
| Long Insert | 151 bp; Mate-pair | 10-12 kb | 223,358,676 | 67,454,320,152 |
| Total | n/a | n/a | 763,516,406 | 230,581,954,612 |


## Step 1:  Read trimming and filtering
