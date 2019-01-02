# Cleaning the Raw Sequencing Reads
This section will start with the raw sequencing data and perform a series a cleaning steps to prepare the sequences for the genome assembly.  The various steps include:
1.  Filtering low-quality reads, Trimming low-quality bases, adapter identification and removal
    - Program: [fastp](https://github.com/OpenGene/fastp) for paired-end reads 
2.  Removing identical read pairs
    - Program: [fastuniq](https://sourceforge.net/projects/fastuniq/)
3.  Removing Mate-pair reads that overlap
    - Program: [fastq-join](https://github.com/brwnj/fastq-join)
4.  Removing reads that map conclusively to the American Shad mitochondrial genome
    - A mitgenome is already available, so we want to minimize their presence
5.  Kmer counting and Error-correcting the sequencing reads
    - Program: Undecided (Dsk, Quake, Musket, BFC...)

Sometimes the code below only shows the code for a single run, and runs may be repeated for different files. For reference to the amount of resources required, see the accompanying .sh scripts in the [Data](./Data) folder.

### Raw Data Summary:

| Name | Type | Insert Size | # Paired Reads | # Bases | Q20 bases | Q30 Bases |
| --- | --- | --- | --- | --- | --- | --- |
| PE500 | 151 bp; Paired-end | TBD | 313,465,270 | 94,666,511,540 | 88.2% | 81.4% |
| MP5k | 151 bp; Mate-pair | 5-7 kb | 226,692,460 | 68,461,122,920 | 93.1% | 85.3% |
| MP10k | 151 bp; Mate-pair | 10-12 kb | 223,358,676 | 67,454,320,152 | 92.8% | 85.0% |
| __Total__ | n/a | n/a | 763,516,406 | 230,581,954,612 | 93.0% | 85.5% |


## Step 1:  Read trimming and filtering
Here the new software [fastp v0.19.4](https://github.com/OpenGene/fastp) was used to trim the paired-end sequences. It combines a QC (Similar to FastQC) along with various trimming and filtering functions. The publication can be found here:  
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

_Summary of Results After Cleaning:_  

| Name | \# Paired Reads | \# Bases | Q20 bases | Q30 Bases |
| --- | --- | --- | --- | --- |
| PE500 | 280,454,045 | 81,520,790,896 | 96.0% | 89.6% |
| MP5k | 207,677,745 | 62,423,641,430 | 95.2% | 88.1% |
| MP10k | 194,228,811 | 58,364,280,836 | 95.3% | 88.1% |
| __Total__ | 682,360,601 | 202,308,713,162 | 95.5% | 88.7% |



## Step 2:  Remove duplicated pairs
Here the software [fastuniq v1.1](https://sourceforge.net/projects/fastuniq) was used to remove a read pair if both the forward and reverse reads match (identical or nearly identical). The publication can be found here:  
Xu H, Luo X, Qian J, Pang X, Song J, Qian G, et al. (2012) FastUniq: A Fast De Novo Duplicates Removal Tool for Paired Short Reads. PLoS ONE 7(12): e52249. https://doi.org/10.1371/journal.pone.0052249  

  _Abstract_  
  "The presence of duplicates introduced by PCR amplification is a major issue in paired short reads from next-generation sequencing platforms. These duplicates might have a serious impact on research applications, such as scaffolding in whole-genome sequencing and discovering large-scale genome variations, and are usually removed. We present FastUniq as a fast de novo tool for removal of duplicates in paired short reads. FastUniq identifies duplicates by comparing sequences between read pairs and does not require complete genome sequences as prerequisites. FastUniq is capable of simultaneously handling reads with different lengths and results in highly efficient running time, which increases linearly at an average speed of 87 million reads per 10 minutes"  

_Installation:_
```bash
# Install fastuniq
wget https://sourceforge.net/projects/fastuniq/files/FastUniq-1.1.tar.gz
tar -zxvf FastUniq-1.1.tar.gz
cd FastUniq/source
make
```

_Run fastuniq job_  
An example run is shown below, using the script [fastuniq.sh](./Data/fastuniq.sh).  Unfortunately, it is single threaded and requires a lot of memory (>200G for these files), but it runs fast (<2 hours).
```bash
# Submit fastuniq job for the PE500 data
sbatch \
   -J PE500 \
   -o FastUniq.PE500.out \
   -e FastUniq.PE500.err \
   -p common-large \
   --mem=235G \
   fastuniq.sh \
   PE500
```
Here is the general content of the fastuniq job script:
```bash
# Read in file name stem
n=PE500

# Uncompress the trimmed reads from fastp (above)
# Notice we don't change the contents of the file, but rather write to a new one
echo "Unzipping the trimmed reads..."
zcat ${n}_F.trimmed.fq.gz > ${n}.F.fq
zcat ${n}_R.trimmed.fq.gz > ${n}.R.fq

# Make input file (pairs of fastq files)
ls ${n}.{F,R}.fq > ${n}.files

echo "Running FastUniq..."
fastuniq \
   -i ${n}.files \
   -t q \
   -c 0 \
   -o ${n}_F.trimmed.uniq.fq \
   -p ${n}_R.trimmed.uniq.fq
echo "Finished FastUniq..."

# Remove files not needed
rm -rf ${n}.files ${n}.F.fq ${n}.R.fq

# Compress reads
echo "Compressing files..."
gzip ${n}_F.trimmed.uniq.fq
gzip ${n}_R.trimmed.uniq.fq
echo "Finished compressing files..."
```
_Parameters Explained:_
- -i file :: input file with list of the pairs of files, __*does not recognize gzip*__
- -t q :: output two fastq formatted files (forward and reverse)
- -c 0 :: don't change the read IDs
- -o file :: output file name for forward reads
- -p file :: output file name for reverse reads

_Summary of Results After Removing Duplicated Pairs:_  

| Name | \# Paired Reads Before | \# Paired Reads After | \# Bases After | Q20 bases After | Q30 Bases After |
| --- | --- | --- | --- | --- | --- |
| PE500 | 280,454,045 | 275,015,380 | 79,988,291,387 | 95.9% | 89.5% |
| MP5k | 207,677,745 | 118,415,796 | 35,530,415,027 | 92.7% | 83.5% |
| MP10k | 194,228,811 | 100,099,262 | 30,047,301,234 | 92.2% | 82.6% |
| __Total__ | 682,360,601 | 493,530,438 | 145,566,007,648 | 94.4% | 86.6% |

__*Note*__  
Use the command ```seqtk fqchk -q20 <(zcat *.trimmed.fq.gz)``` to get the count of bases >=Q20 for all trimmed sequences, or other combination of files and quality score values.

## Step 3:  Remove overlapping mate-pair reads.
Here the software [fastq-join v1.3.1](https://github.com/brwnj/fastq-join) was used to remove mate-pair reads (long insert) that overlap.  Since the insert size is expected to be large (>5kb), overlapping reads are thus too short of an insert or otherwise are error-prone. This step was not performed on paired-end reads since they are expected to overlap at times. The publication can be found here:  
Erik Aronesty (2013). TOBioiJ : "Comparison of Sequencing Utility Programs", http://doi.org/10.2174/1875036201307010001

  _From the paper_  
  "Several high-throughput sequencing technologies perform “paired end” sequencing, often used for improving alignment specificity. In this technique, the fragments are sequenced from both ends (Fig. 2). With long insert sizes, these can be used for improved assembly (known as scaffolding), transcriptome determination and other applications. However, when the insert size is shorter than the total number of bases read, the sequencer will read the same region twice, once in one direction and then again in the other. These reads can be “joined” using several publically available tools, including SeqPrep, fastq-join, [mergePairs.py](code.google.com/p/standardized-velvet-assembly-report), and [Audy’s “stitch” program](github.com/audy/stitch). These overlapping regions will then be overrepresented (sequenced twice for the same molecule), and this may result in bias, especially for exome capture or other smaller regions. For this reason, and for testing library preparation, “joining” may be done."

_Installation:_
```bash
# Install fastq-join
git clone https://github.com/brwnj/fastq-join
cd fastq-join
make
```
_Run fastq-join job_  
An example run is shown below, using the script [fastq-join.sh](./Data/fastq-join.sh).  Unfortunately, it is also single threaded and requires a lot of memory (>200G for these files).  Remember, it was only run on the two mate-pair files. Running time took 2.5 hours.
```bash
# Submit fastq-join job for the MP5k data
sbatch \
   -J MP5k \
   -o fastq-join.MP5k.out \
   -e fastq-join.MP5k.err \
   fastq-join.sh \
   MP5k
```
Here is the general content of the fastq-join job script:
```bash
# Read in file name stem
n=MP5k

# Uncompress reads
echo "Unzipping the trimmed and deduplicated reads..."
zcat ${n}_F.trimmed.uniq.fq.gz > ${n}.F.fq
zcat ${n}_R.trimmed.uniq.fq.gz > ${n}.R.fq

# Run fastq-join
echo "Running fastq-join"
fastq-join \
	-o ${n}. \
	-v ' ' \
	-p 10 \
	-m 10 \
	-r ${n}.stitch \
	${n}.F.fq \
	${n}.R.fq
echo "Finished FastUniq..."

# Compress reads
echo "Compressing files..."
mv ${n}.un1 ${n}_F.trimmed.uniq.unj.fq
gzip ${n}_F.trimmed.uniq.unj.fq
mv ${n}.un2 ${n}_R.trimmed.uniq.unj.fq
gzip ${n}_R.trimmed.uniq.unj.fq
mv ${n}.join ${n}.joined.fq
gzip ${n}.joined.fq
echo "Finished compressing files..."

# Cleanup
rm -rf ${n}.stitch ${n}.F.fq ${n}.R.fq
```
_Parameters Explained:_
- -o stem :: output file name stem, un1, un2, or join are added
- -v ' ' :: this character (a space here), is used to separate the read ID lines (normal for illumina)
- -p 10 :: N-percent maximum difference
- -m 10 :: N-minimum overlap
- -r file :: Verbose stitch length report
- two input files, __*does not recognize gzip*__

_Summary of Results After Removing Overlapping Mate-Pairs:_  

| Name | \# Paired Reads After | \# Bases After | Q20 bases After | Q30 Bases After |
| --- | --- | --- | --- | --- |
| MP5k | 99,227,071 | 29,883,917,490 | 92.3% | 82.8% |
| MP10k | 80,727,818 | 24,309,217,299 | 91.8% | 81.9% |


## Step 4:  Remove mitochondrial reads
Since a mitogenome sequence for American shad already exists, it is useful to remove mitochondrial sequences from the dataset.  This reduces the overall computational burden and facilitates less cleanup of the final, assembled scaffolds.  It is possible this may filter some occassional nuclear-mitochondrial insertions, but we can accept that since the read pair information will help minimize this.  We use the `efetch` command from the [NCBI E-utilities toolset](https://www.ncbi.nlm.nih.gov/home/tools/) to download the mitogenome sequence.  The mitogenome was published in:  
Bi YH and Chen XW (2011). Mitochondrial genome of the American shad _Alosa sapidissima_. Mitochondrial DNA 22(1-2):9-11. http://doi.org/10.3109/19401736.2010.551659.

_Download the mitogenome_
```bash
efetch \
   -db nucleotide \
   -format fasta \
   -id NC_014690.1 >> Asap_mito.fasta
```
_Do the Mapping and Extract the Remaining Reads_  
This uses `bowtie2`, which has been enabled for mate-pair reads.  Only examples are shown below, please see [remove-mitoPE500.sh](./Data/remove-mitoPE500.sh) script for full code.
```bash
# Build index of reference
bowtie2-build Asap_mito.fasta Asap_mito

# Run mapping script, remember the parameters differ for each of the three libraries.
sbatch remove-mitoPE500.sh

# Do Mapping for PE reads
bowtie2 \
   --phred33 \
   -q \
   --very-sensitive \
   --minins 0 \
   --maxins 500 \
   --fr \
   --threads 8 \
   --reorder \
   -x Asap_mito \
   -1 PE500_F.trimmed.uniq.fq.gz \
   -2 PE500_R.trimmed.uniq.fq.gz | \
   samtools1.3 view -b -F 2 | \
   samtools1.3 sort -T PE500.tmp -n -O bam | \
   bedtools bamtofastq -i - -fq PE500_F.trimmed.uniq.noMito.fq -fq2 PE500_R.trimmed.uniq.noMito.fq

# Compress the resulting reads
gzip PE500_F.trimmed.uniq.noMito.fq
gzip PE500_R.trimmed.uniq.noMito.fq
```
_Parameters Explained:_
- --phred33 :: use phred33 offset for quality scores (standard for recent illumina data)
- -q :: fastq format
- --very-sensitive :: end-to-end alignment, -D 20 -R 3 -N 0 -L 20 -i S,1,0.50
- --minins 0 :: minimum insert size
- --maxins 500 :: maximum insert size
- --fr :: paired-end orientation  *__SWITCH TO --rf FOR MATE-PAIR READS__*
- --threads 8 :: use 8 cpus
- --reorder :: sort the output same file
- -x Asap_mito :: basename for the indexed reference to map against
- -1/-2 :: forward and reverse read file names.  *__Recognizes gzip__*
- Samtools view
  - -b :: output bam format
  - -F 2 :: exclude all properly paired and mapped reads
- Samtools sort
  - -n :: sort by read name for forward and reverse reads are next to each other
  - -O bam :: output bam format
  - -T PE500.tmp :: temporary file names for sorting bam files.  Set this or else they may overwrite each other.
- Bedtools bamtofastq
  - -i :: input bam file, uses standard input here
  - -fq/-fq2 :: forward and reverse output fastq files.

_Summary of Results After Removing Mitochondrial Reads:_  

| Name | \# Paired Reads After | \# Bases After | Q20 bases After | Q30 Bases After |
| --- | --- | --- | --- | --- |
| PE500 | 232,020,941 | 67,978,401,922  | 97.6 | 92.4 |
| MP5k  | 76,414,698  | 22,813,532,162  | 95.4 | 87.8 |
| MP10k | 60,302,741  | 17,994,765,464  | 95.1 | 87.2 |
| __Total__ | 368,738,380 | 108,786,699,548 | 96.7 | 90.5 |

For the MP5k and MP10k reads see [remove-mitoMP5k.sh](./Data/remove-mitoMP5k.sh) and [remove-mitoMP10k.sh](./Data/remove-mitoMP10k.sh) scripts.


## Step 5:  Error Correction
[Salzberg et al. (2012)](https://dx.doi.org/10.1101%2Fgr.131383.111) have shown that the error correction of sequencing reads can greatly improve the _de novo_ assembly of genomes, especially when the assembly program (e.g., ABYSS) does include a built-in error correction step. Here we use the software [musket v1.1](http://musket.sourceforge.net/homepage.htm) to error-correct the cleaned sequencing reads. Although numerous error-correction tools exist, it has been empirically demonstrated that [musket](http://musket.sourceforge.net/homepage.htm) consistently outperforms many other algorithms in the balance of speed and sensitivity while rarely introducing a new error ([Heydari et al. 2017](https://dx.doi.org/10.1186%2Fs12859-017-1784-8); [Akogwu et al. 2016](https://doi.org/10.1186/s40246-016-0068-0)). The publication can be found here:  
Liu Y, Schroeder J, and Schmidt B (2013) Musket: a multistage k-mer spectrum based error corrector for Illumina sequence data. _Bioinformatics_ 29(3): 308-315. https://doi.org/10.1093/bioinformatics/bts690  

_From the paper_  
"__Motivation:__ The imperfect sequence data produced by next-generation sequencing technologies have motivated the development of a number of short-read error correctors in recent years. The majority of methods focus on the correction of substitution errors, which are the dominant error source in data produced by Illumina sequencing technology. Existing tools either score high in terms of recall or precision but not consistently high in terms of both measures.  
__Results:__ In this article, we present Musket, an efficient multistage k-mer-based corrector for Illumina short-read data. We use the k-mer spectrum approach and introduce three correction techniques in a multistage workflow: two-sided conservative correction, one-sided aggressive correction and voting-based refinement. Our performance evaluation results, in terms of correction quality and de novo genome assembly measures, reveal that Musket is consistently one of the top performing correctors. In addition, Musket is multi-threaded using a master–slave model and demonstrates superior parallel scalability compared with all other evaluated correctors as well as a highly competitive overall execution time."  

_Installation:_
```bash
# Install musket v1.1
wget https://sourceforge.net/projects/musket/files/musket-1.1.tar.gz
tar -zxvf musket-1.1.tar.gz 
cd musket-1.1
make
```
_Perform the Error Correction_ - See the [musket.sh](./Data/musket.sh)  
```bash
musket \
   -k 21 536870912 \
   -p 12 \
   -omulti corrected \
   -inorder \
   -zlib \
   -lowercase \
   PE500_F.trimmed.uniq.noMito.fq.gz \
   PE500_R.trimmed.uniq.noMito.fq.gz \
   MP5k_F.trimmed.uniq.unj.noMito.fq.gz \
   MP5k_R.trimmed.uniq.unj.noMito.fq.gz \
   MP10k_F.trimmed.uniq.unj.noMito.fq.gz \
   MP10k_R.trimmed.uniq.unj.noMito.fq.gz
```
_Parameters Explained:_
- --phred33 :: use phred33 offset for quality scores (standard for recent illumina data)

____________________________
## Summary of Results

| Step | PE500 | MP5k | MP10k | __Total__ |
| --- | --- | --- | --- | --- |
| Raw Reads | 313,465,270 | 226,692,460 | 223,358,676 | 763,516,406 |
| Raw Bases | 94,666,511,540 | 68,461,122,920 | 67,454,320,152 | 230,581,954,612 |
| Trimmed Reads | 239,477,910 | 178,871,091 | 167,372,392 | 585,721,393 |
| Trimmed Bases | 70,144,071,953 | 53,563,193,951 | 50,109,673,703 | 173,816,939,607 |
| Trimmed & Deduped Reads | 233,830,309 | 93,007,002 | 76,805,039 | 403,642,350 |
| Trimmed & Deduped Bases | 68,514,025,011 | 27,714,871,797 | 22,869,981,489 | 119,098,878,297 |
| Trimmed, Deduped, Uniq Reads | n/a | 76,421,553 | 60,334,373 | n/a |
| Trimmed, Deduped, Uniq Bases | n/a | 22,815,584,213 | 17,996,089,046 | n/a |
| Trimmed, Deduped, Uniq, no Mito Reads | 232,020,941 | 76,414,698 | 60,329,949 | 368,765,588 |
| Trimmed, Deduped, Uniq, no Mito Bases | 67,978,401,922 | 22,813,532,162 | 17,994,765,464 | 108,786,699,548 |
| Error-corrected Reads | --- | --- | --- | --- |
| Error-corrected Bases | --- | --- | --- | --- |  


Note: use Pilon (Broad Github) for checking and improving assembly)
