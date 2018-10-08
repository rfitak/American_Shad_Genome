# Raw Sequencing Read Cleaning
This section will start with the raw sequencing data and perform a series a cleaning steps to prepare the sequences for the genome assembly.  The various steps include:
1.  Filtering low-quality reads, Trimming low-quality bases, adapter identification and removal
  a.  Program: [Fastp](https://github.com/OpenGene/fastp)
2.  Removing identical read pairs
  a.  Program: [FastUniq](https://sourceforge.net/projects/fastuniq/)
3.  Removing Mate-pair reads that overlap
  a.  Program: [Fastq-join](https://github.com/brwnj/fastq-join)
4.  Removing reads that map conclusively to the American Shad mitochondrial genome
  a.  a mitgenome is already available, so we want to minimize their presence
5.  Kmer counting and Error-correcting the sequencing reads
  a.  Program: Undecided (Dsk, Quake, Musket, BFC...)

### Raw Data Summary:
insert table here....


## Step 1:  Read trimming and filtering
