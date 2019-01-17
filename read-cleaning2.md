# Cleaning the Raw Sequencing Reads
This section will start with the raw sequencing data and perform a series a cleaning steps to prepare the sequences for the genome assembly.  The various steps include:
1.  Process mate-pair (MP) reads, separating into proper MP and paired-end (PE) reads
    - Program: [NxTrim](https://github.com/sequencing/NxTrim)
2.  Process PE reads into overlapping single-end (SE) reads
    - Program: [pear](http://www.exelixis-lab.org/web/software/pear)   
    - Alternatively, one can use [flash](https://ccb.jhu.edu/software/FLASH/)
3.  Filtering low-quality reads, Trimming low-quality bases, adapter identification and removal
    - Program: [fastp](https://github.com/OpenGene/fastp) for paired-end reads 
2.  Removing identical read pairs
    - Program: [fastuniq](https://sourceforge.net/projects/fastuniq/)
    
```    
3.  Removing Mate-pair reads that overlap
    - Program: [fastq-join](https://github.com/brwnj/fastq-join)
4.  Removing reads that map conclusively to the American Shad mitochondrial genome
    - A mitgenome is already available, so we want to minimize their presence
5.  Kmer counting and Error-correcting the sequencing reads
    - Program: [musket v1.1](http://musket.sourceforge.net/homepage.htm)
```
Sometimes the code below only shows the code for a single run, and runs may be repeated for different files. For reference to the amount of resources required, see the accompanying .sh scripts in the [Data](./Data) folder.

### Raw Data Summary:

| Name | Type | Insert Size | # Paired Reads | # Bases | Q20 bases | Q30 Bases |
| --- | --- | --- | --- | --- | --- | --- |
| PE500 | 151 bp; Paired-end | TBD | 313,465,270 | 94,666,511,540 | 88.2% | 81.4% |
| MP5k | 151 bp; Mate-pair | 5-7 kb | 226,692,460 | 68,461,122,920 | 93.1% | 85.3% |
| MP10k | 151 bp; Mate-pair | 10-12 kb | 223,358,676 | 67,454,320,152 | 92.8% | 85.0% |
| __Total__ | n/a | n/a | 763,516,406 | 230,581,954,612 | 93.0% | 85.5% |

_See the Output HTML/PDF Files from ```fastp``` below:_
- [PE500](./Data/PE500.pdf)
- [MP5k](./Data/MP5k.pdf)
- [MP10k](./Data/MP10k.pdf)


## Step 1:  Separate the MP reads into MP and PE reads
Here the software [NxTrim v0.4.3-6eb8d5e](https://github.com/sequencing/NxTrim) was used to separate the MP reads. NxTrim removes the Nextera Mate Pair junction adapters and categorizes reads according to the orientation implied by the adapter location. The publication can be found here:  
O’Connell J, Schulz-Trieglaff O, Carlson E, Hims MH, Gormley NA, Cox AJ. (2015) NxTrim: optimized trimming of Illumina mate pair reads. _Bioinformatics_ 31(12):2035–2037. https://doi.org/10.1093/bioinformatics/btv057

_Installation:_
```bash
# Install NxTrim using git
git clone https://github.com/sequencing/NxTrim.git
cd NxTrim
make
```
_Run NxTrim_  
An example run is shown below for the 5-7kb insert library, please see the scripts [nxtrim_MP5k.sh](./Data/nxtrim_MP5k.sh), [nxtrim_MP10k.sh](./Data/nxtrim_MP10k.sh), for more details on Job information.
```bash
# Assign read file names
fwd="5-7kb_S16_L002_R1_001.fastq.gz"
rev="5-7kb_S16_L002_R2_001.fastq.gz"
name="MP5k"

# Run nxtrim
nxtrim \
   -1 ${fwd} \
   -2 ${rev} \
   -O ${name} \
   --rf \
   --separate \
   -a \
   -l 50
```
_Parameters Explained:_
- -1/2 :: input forward and reverse read files, recognizes gzip
- -O :: output prefix
- --rf :: leave mate pair reads in RF orientation \[by default are flipped into FR\]
- --separate :: output paired reads in separate files (prefix_R1/prefix_r2). Default is interleaved.
- -a :: more aggressive adapter search (see docs/adapter.md)
- -l :: minimum length cutoff

### Output Summary
_MP5k Reads_
```
Trimming summary:
226692460 / 226692460	( 100.00% )	reads passed chastity/purity filters.
15085 / 226692460	( 0.01% )	reads had multiple copies of adapter (filtered).
970809 / 226677375	( 0.43% )	read pairs were ignored because template length appeared less than read length
225706566 remaining reads were trimmed
72226739 / 225706566	( 32.00% )	read pairs had MP orientation
87847026 / 225706566	( 38.92% )	read pairs had PE orientation
60434557 / 225706566	( 26.78% )	read pairs had unknown orientation
5198244 / 225706566	( 2.30% )	were single end reads
12147103 / 225706566	( 5.38% )	extra single end reads were generated from overhangs
```
_MP10k Reads_
```
Trimming summary:
223358676 / 223358676	( 100.00% )	reads passed chastity/purity filters.
16545 / 223358676	( 0.01% )	reads had multiple copies of adapter (filtered).
1000265 / 223342131	( 0.45% )	read pairs were ignored because template length appeared less than read length
222341866 remaining reads were trimmed
70317539 / 222341866	( 31.63% )	read pairs had MP orientation
92595412 / 222341866	( 41.65% )	read pairs had PE orientation
52979519 / 222341866	( 23.83% )	read pairs had unknown orientation
6449396 / 222341866	( 2.90% )	were single end reads
11670353 / 222341866	( 5.25% )	extra single end reads were generated from overhangs
```

## Step 2:  Process PE overlaps
The software [pear v0.9.11](http://www.exelixis-lab.org/web/software/pear) was used to merge paired-end reads. The resulting longer reads are SE but can significantly improve genome assemblies. The publication can be found here:  
Zhang J, Kobert K, Flouri T, Stamatakis A (2014) PEAR: a fast and accurate Illumina Paired-End reAd mergeR. _Bioinformatics_ 30(5):614-20. https://doi.org/10.1093/bioinformatics/btt593  
Alternatively, but not shown below, I tried running [flash v1.2.11](https://ccb.jhu.edu/software/FLASH/), but I liked pear much better.  You can see the script [flash.sh](./Data/flash.sh) if this is of interest.

_Installation:_
```bash
# Downloaded from http://www.exelixis-lab.org/web/software/pear
gunzip pear-src-0.9.11.tar.gz
tar -xvf pear-src-0.9.11.tar
cd pear-src-0.9.11
./configure PREFIX=/dscrhome/frr6/bin/
make
```

_Run Pear_  
An example run is shown below.  **_NOTE:_** We have to process both the PE500 reads and the PE reads produced from NxTrim above.  Please see the script [pear.sh](./Data/pear.sh) for more details on Job information.
```bash
# Merge PE reads produced from NxTrim
zcat \
   MP5k_R1.pe.fastq.gz \
   MP10k_R1.pe.fastq.gz \
   | gzip > PE_mp.F.fq.gz
zcat \
   MP5k_R2.pe.fastq.gz \
   MP10k_R2.pe.fastq.gz \
   | gzip > PE_mp.R.fq.gz

# Set file names
fwd1="gDNA_S18_L002_R1_001.fastq.gz"
rev1="gDNA_S18_L002_R2_001.fastq.gz"
fwd2="PE_mp.F.fq.gz"
rev2="PE_mp.R.fq.gz"

# PE500 reads
pear \
   -o PE500.pear \
   -f ${fwd1} \
   -r ${rev1} \
   -j 12 \
   -k

# From the MP reads
pear \
   -o PE_mp.pear \
   -f ${fwd2} \
   -r ${rev2} \
   -j 12 \
   -k

# Compress reads
gzip PE500.pear.assembled.fastq
gzip PE500.pear.discarded.fastq
gzip PE500.pear.unassembled.forward.fastq
gzip PE500.pear.unassembled.reverse.fastq
gzip PE_mp.pear.assembled.fastq
gzip PE_mp.pear.discarded.fastq
gzip PE_mp.pear.unassembled.forward.fastq
gzip PE_mp.pear.unassembled.reverse.fastq
```

_Parameters Explained:_
- -o :: output prefix, **does not gzip**
- -f/r :: input forward and reverse read files, recognizes gzip
- -j :: number of threads to use
- -k :: do not reverse-complement the reverse reads in the output file

### Output Summary

x  
x  
x  
x  
x  
x  
x  
x  

## Step 3:  Read trimming and filtering
Here the new software [fastp v0.19.6](https://github.com/OpenGene/fastp) was used to trim the PE reads. It combines a QC (Similar to FastQC) along with various trimming and filtering functions. The publication can be found here:  
Shifu Chen, Yanqing Zhou, Yaru Chen, Jia Gu; fastp: an ultra-fast all-in-one FASTQ preprocessor, Bioinformatics, Volume 34, Issue 17, 1 September 2018, Pages i884–i890, https://doi.org/10.1093/bioinformatics/bty560

_Installation:_
```bash
# Install fastp using git
git clone https://github.com/OpenGene/fastp.git
cd fastp
make
```

_Run fastp_  
An example run is shown below, please see the scripts [trimPE500.sh](./Data/trimPE500.sh), [trimMP5k.sh](./Data/trimMP5k.sh), and [trimMP10k.sh](./Data/trimMP10k.sh) for more details on Job information.
```bash
# Assign names to each forward and reverse sequence reads file
fwd="gDNA_S18_L002_R1_001.fastq.gz"
rev="gDNA_S18_L002_R2_001.fastq.gz"
name="PE500"

# Run fastp
fastp \
   -i ../RAW_READS/${fwd} \
   -I ../RAW_READS/${rev} \
   -o ${name}_F.trimmed.fq.gz \
   -O ${name}_R.trimmed.fq.gz \
   -n 5 \
   -q 20 \
   -u 30 \
   --length_required=70 \
   --low_complexity_filter \
   --complexity_threshold=20 \
   --cut_by_quality3 \
   --cut_by_quality5 \
   --cut_window_size=4 \
   --cut_mean_quality=20 \
   --trim_poly_g \
   --poly_g_min_len=10 \
   --overrepresentation_analysis \
   --json=${name}.json \
   --html=${name}.html \
   --report_title="$name" \
   --thread=8
```
_Parameters Explained:_
- -i/-I :: input forward and reverse read files, recognizes gzip
- -o/-O :: output forward and reverse read files, recognizes gzip
- -n 5 :: if one read's number of N bases is >5, then this read pair is discarded
- -q 20 :: minimum base quality score to keep
- -u 30 :: Percent of bases allowed to be less than q in a read
- --length_required=70 :: minimum read length to keep after trimming
- --low_complexity_filter :: filter sequences with a low complexity
- --complexity_threshold=20 :: threshold for sequence complexity filter
- --cut_by_quality3 :: use a 3' sliding window trimmer, like trimmomatic
- --cut_by_quality5 :: use a 5' sliding window trimmer, like trimmomatic
- --cut_window_size=4 :: window size for the trimming
- --cut_mean_quality=20 :: mean base score across the window required, or else trim the last base
- --trim_poly_g :: removes poly G tails for NovaSeq reads
- --poly_g_min_len=10 :: minimum length for poly G removal
- --overrepresentation_analysis :: look for overrepresented sequences, like adapters
- --json=${name}.json :: output file name, JSON format
- --html=${name}.html :: output file name, HTML format
- --report_title="$name" :: output report tile
- --thread=8 :: number of cpus to use

_See the Output HTML/PDF Files:_
- [PE500](./Data/PE500.pdf)
- [MP5k](./Data/MP5k.pdf)
- [MP10k](./Data/MP10k.pdf)

_Final Summary of Cleaning:_  

| Name | \# Paired Reads | \# Bases | Q20 bases | Q30 Bases |
| --- | --- | --- | --- | --- |
| PE500 | 280,454,045 | 81,520,790,896 | 96.0% | 89.6% |
| MP5k | 207,677,745 | 62,423,641,430 | 95.2% | 88.1% |
| MP10k | 194,228,811 | 58,364,280,836 | 95.3% | 88.1% |
| __Total__ | 682,360,601 | 202,308,713,162 | 95.5% | 88.7% |
