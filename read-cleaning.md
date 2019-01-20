# Cleaning the Raw Sequencing Reads
This section will start with the raw sequencing data and perform a series a cleaning steps to prepare the sequences for the genome assembly.  The various steps include:
1.  Process mate-pair (MP) reads, separating into proper MP and paired-end (PE) reads
    - Program: [NxTrim](https://github.com/sequencing/NxTrim)
2.  Filtering low-quality reads, Trimming low-quality bases, adapter identification and removal
    - Program: [fastp](https://github.com/OpenGene/fastp) for paired-end reads   
3.  Process PE reads into overlapping single-end (SE) reads
    - Program: [pear](http://www.exelixis-lab.org/web/software/pear)   
    - Alternatively, one can use [flash](https://ccb.jhu.edu/software/FLASH/)
4.  Removing identical read pairs
    - Program: [clumpify](https://jgi.doe.gov/data-and-tools/bbtools/bb-tools-user-guide/clumpify-guide/) - part of the BBTools package
    - Alternatively, one can use [fastuniq](https://sourceforge.net/projects/fastuniq/), but this is only for PE reads (not SE).
5.  Removing reads that map conclusively to the American Shad mitochondrial genome
    - A mitgenome is already available, so we want to minimize their presence
    - Program [bowtie2](http://bowtie-bio.sourceforge.net/bowtie2/index.shtml) for the mapping
6.  Kmer counting and Error-correcting the sequencing reads
    - Program: [musket v1.1](http://musket.sourceforge.net/homepage.htm)

Sometimes the code below only shows the code for a single run, and runs may be repeated for different files. For reference to the amount of resources required, see the accompanying .sh scripts in the [Data](./Data) folder.

### Raw Data Summary:

| Name | Type | Insert Size | # Paired Reads | # Bases | Q20 bases | Q30 Bases |
| --- | --- | --- | --- | --- | --- | --- |
| PE500 | 151 bp; Paired-end | TBD | 313,465,270 | 94,666,511,540 | 88.2% | 81.4% |
| MP5k | 151 bp; Mate-pair | 5-7 kb | 226,692,460 | 68,461,122,920 | 93.1% | 85.3% |
| MP10k | 151 bp; Mate-pair | 10-12 kb | 223,358,676 | 67,454,320,152 | 92.8% | 85.0% |
| __Total__ | n/a | n/a | 763,516,406 | 230,581,954,612 | 93.0% | 85.5% |


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

## Step 2:  Read trimming and filtering
Here the new software [fastp v0.19.6](https://github.com/OpenGene/fastp) was used to trim all (PE, MP, SE) reads. It combines a QC (Similar to FastQC) along with various trimming and filtering functions. The publication can be found here:  
Chen S, Zhou Y, Chen Y, Gu (2018) fastp: an ultra-fast all-in-one FASTQ preprocessor. _Bioinformatics_ 34(17):i884–i890. https://doi.org/10.1093/bioinformatics/bty560

_Installation:_
```bash
# Install fastp using git
git clone https://github.com/OpenGene/fastp.git
cd fastp
make
```

_Run fastp_  
An example run is shown below, please see the scripts [fastp_PE500.sh](./Data/fastp_PE500.sh), [fastp_MP5k.sh](fastp_MP5k.sh), and [fastp_MP10k.sh](./Data/fastp_MP10k.sh) for more details on Job information.
```bash
# Assign names to each forward and reverse sequence reads file
fwd1="gDNA_S18_L002_R1_001.fastq.gz"
rev1="gDNA_S18_L002_R2_001.fastq.gz"
name1="PE500"

# Trim PE reads
echo "Trimming the PE reads"
fastp \
   -i ${fwd1} \
   -I ${rev1} \
   -o ${name1}_F.trimmed.fq.gz \
   -O ${name1}_R.trimmed.fq.gz \
   --detect_adapter_for_pe \
   --cut_front \
   --cut_tail \
   --cut_window_size=4 \
   --cut_mean_quality=20 \
   --qualified_quality_phred=20 \
   --unqualified_percent_limit=30 \
   --n_base_limit=5 \
   --length_required=50 \
   --low_complexity_filter \
   --complexity_threshold=30 \
   --overrepresentation_analysis \
   --json=${name1}.json \
   --html=${name1}.html \
   --report_title="$name1" \
   --thread=8
```
_Parameters Explained:_
- -i/-I :: input forward and reverse read files, recognizes gzip
- -o/-O :: output forward and reverse read files, recognizes gzip
- --detect_adapter_for_pe :: enable PE adapter trimming
- --cut_front :: enable a 5' sliding window trimmer, like trimmomatic
- --cut_tail :: enable a 3' sliding window trimmer, like trimmomatic
- --cut_window_size=4 :: window size for the trimming
- --cut_mean_quality=20 :: mean base score across the window required, or else trim the last base
- --qualified_quality_phred=20 :: minimum base quality score to keep
- --unqualified_percent_limit=30 :: Percent of bases allowed to be less than q in a read
- --n_base_limit=5 :: if one read's number of N bases is >5, then this read pair is discarded
- --length_required=50 :: minimum read length to keep after trimming
- --low_complexity_filter :: filter sequences with a low complexity
- --complexity_threshold=30 :: threshold for sequence complexity filter
- --overrepresentation_analysis :: look for overrepresented sequences, like adapters
- --json=${name1}.json :: output file name, JSON format
- --html=${name1}.html :: output file name, HTML format
- --report_title="$name1" :: output report tile
- --thread=8 :: number of cpus to use
*__Note:  these parameters were enabled by default__*
- --trim_poly_g :: removes poly G tails for NovaSeq reads
- --poly_g_min_len=10 :: minimum length for poly G removal

_See the Output HTML/PDF Files from ```fastp``` below:_
- [PE500](./Data/PE500.pdf)
- [MP5k](./Data/MP5k.pdf)
- [MP5k_unk](./Data/MP5k_unk.pdf)
- [MP5k_pe](./Data/MP5k_pe.pdf)
- [MP5k_se](./Data/MP5k_se.pdf)
- [MP10k](./Data/MP10k.pdf)
- [MP10k_unk](./Data/MP10k_unk.pdf)
- [MP10k_pe](./Data/MP10k_pe.pdf)
- [MP10k_se](./Data/MP10k_se.pdf)

### Output Summary
_PE500 Reads_
```
Detecting adapter sequence for read1...
Illumina TruSeq Adapter Read 1: AGATCGGAAGAGCACACGTCTGAACTCCAGTCA

Detecting adapter sequence for read2...
Illumina TruSeq Adapter Read 2: AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT

Read1 before filtering:
total reads: 313465270
total bases: 47333255770
Q20 bases: 44459515886(93.9287%)
Q30 bases: 41161938102(86.962%)

Read1 after filtering:
total reads: 282679799
total bases: 40866088764
Q20 bases: 39259694128(96.0691%)
Q30 bases: 36722535538(89.8607%)

Read2 before filtering:
total reads: 313465270
total bases: 47333255770
Q20 bases: 43740886904(92.4105%)
Q30 bases: 40215115322(84.9617%)

Read2 after filtering:
total reads: 282679799
total bases: 40844727907
Q20 bases: 39168769257(95.8968%)
Q30 bases: 36532722615(89.4429%)

Filtering result:
reads passed filter: 565359598
reads failed due to low quality: 56453630
reads failed due to too many N: 7128
reads failed due to too short: 4751908
reads failed due to low complexity: 358276
reads with adapter trimmed: 117911171
bases trimmed due to adapters: 3697697721

Duplication rate: 3.22418%

Insert size peak (evaluated by paired-end reads): 151

JSON report: PE500.json
HTML report: PE500.html

fastp v0.19.6, time used: 3677 seconds
```
_MP5k Reads_
```
# MP5k MP reads
Detecting adapter sequence for read1...
No adapter detected for read1

Detecting adapter sequence for read2...
No adapter detected for read2

Read1 before filtering:
total reads: 72226739
total bases: 8555203278
Q20 bases: 8169036254(95.4862%)
Q30 bases: 7611101112(88.9646%)

Read1 after filtering:
total reads: 69302647
total bases: 8211891813
Q20 bases: 7907272937(96.2905%)
Q30 bases: 7396093669(90.0656%)

Read2 before filtering:
total reads: 72226739
total bases: 8652737388
Q20 bases: 8158905710(94.2928%)
Q30 bases: 7528610405(87.0084%)

Read2 after filtering:
total reads: 69302647
total bases: 8269710924
Q20 bases: 7909224976(95.6409%)
Q30 bases: 7337874335(88.7319%)

Filtering result:
reads passed filter: 138605294
reads failed due to low quality: 5687612
reads failed due to too many N: 1332
reads failed due to too short: 134194
reads failed due to low complexity: 25046
reads with adapter trimmed: 88598
bases trimmed due to adapters: 4520619

Duplication rate: 79.9732%

Insert size peak (evaluated by paired-end reads): 0

JSON report: MP5k.json
HTML report: MP5k.html

fastp v0.19.6, time used: 1021 seconds

# MP5k unk reads
Detecting adapter sequence for read1...
No adapter detected for read1

Detecting adapter sequence for read2...
No adapter detected for read2

Read1 before filtering:
total reads: 60434557
total bases: 9103963533
Q20 bases: 8383688714(92.0883%)
Q30 bases: 7644980028(83.9742%)

Read1 after filtering:
total reads: 50514384
total bases: 7593290562
Q20 bases: 7236813461(95.3054%)
Q30 bases: 6701035903(88.2494%)

Read2 before filtering:
total reads: 60434557
total bases: 9104941968
Q20 bases: 8033994501(88.2377%)
Q30 bases: 7129774671(78.3066%)

Read2 after filtering:
total reads: 50514384
total bases: 7590443800
Q20 bases: 7076651939(93.2311%)
Q30 bases: 6410485139(84.4547%)

Filtering result:
reads passed filter: 101028768
reads failed due to low quality: 19123774
reads failed due to too many N: 1782
reads failed due to too short: 624196
reads failed due to low complexity: 90594
reads with adapter trimmed: 57920
bases trimmed due to adapters: 3690502

Duplication rate: 63.1683%

Insert size peak (evaluated by paired-end reads): 0

JSON report: MP5k_unk.json
HTML report: MP5k_unk.html

fastp v0.19.6, time used: 986 seconds

# MP5k PE reads
Detecting adapter sequence for read1...
No adapter detected for read1

Detecting adapter sequence for read2...
No adapter detected for read2

Read1 before filtering:
total reads: 87847026
total bases: 10620316674
Q20 bases: 9987265240(94.0392%)
Q30 bases: 9214906794(86.7668%)

Read1 after filtering:
total reads: 79605083
total bases: 9409417239
Q20 bases: 8997865087(95.6262%)
Q30 bases: 8356854855(88.8137%)

Read2 before filtering:
total reads: 87847026
total bases: 10742746146
Q20 bases: 9980076411(92.9006%)
Q30 bases: 9114573642(84.844%)

Read2 after filtering:
total reads: 79605083
total bases: 9317609181
Q20 bases: 8837411964(94.8463%)
Q30 bases: 8123820342(87.1878%)

Filtering result:
reads passed filter: 159210166
reads failed due to low quality: 12503538
reads failed due to too many N: 1382
reads failed due to too short: 3777180
reads failed due to low complexity: 201786
reads with adapter trimmed: 16886874
bases trimmed due to adapters: 934315765

Duplication rate: 58.4791%

Insert size peak (evaluated by paired-end reads): 151

JSON report: MP5k_pe.json
HTML report: MP5k_pe.html

fastp v0.19.6, time used: 1274 seconds

# MP5k SE reads
Detecting adapter sequence for read1...
No adapter detected for read1

Read1 before filtering:
total reads: 17345347
total bases: 1152136349
Q20 bases: 1103155168(95.7487%)
Q30 bases: 1030205878(89.417%)

Read1 after filtering:
total reads: 16861797
total bases: 1124360058
Q20 bases: 1085461753(96.5404%)
Q30 bases: 1017086457(90.4591%)

Filtering result:
reads passed filter: 16861797
reads failed due to low quality: 351338
reads failed due to too many N: 55
reads failed due to too short: 131753
reads failed due to low complexity: 404
reads with adapter trimmed: 0
bases trimmed due to adapters: 0

Duplication rate (may be overestimated since this is SE data): 69.1975%

JSON report: MP5k_se.json
HTML report: MP5k_se.html

fastp v0.19.6, time used: 100 seconds
```
_MP10k Reads_
```
# MP10k MP reads
Detecting adapter sequence for read1...
No adapter detected for read1

Detecting adapter sequence for read2...
No adapter detected for read2

Read1 before filtering:
total reads: 70317539
total bases: 8252846187
Q20 bases: 7888440507(95.5845%)
Q30 bases: 7356591994(89.1401%)

Read1 after filtering:
total reads: 67429656
total bases: 7916626307
Q20 bases: 7629893125(96.3781%)
Q30 bases: 7143698146(90.2366%)

Read2 before filtering:
total reads: 70317539
total bases: 8353353046
Q20 bases: 7861552795(94.1125%)
Q30 bases: 7239715878(86.6684%)

Read2 after filtering:
total reads: 67429656
total bases: 7975344398
Q20 bases: 7616341234(95.4986%)
Q30 bases: 7053148356(88.4369%)

Filtering result:
reads passed filter: 134859312
reads failed due to low quality: 5602906
reads failed due to too many N: 1352
reads failed due to too short: 151746
reads failed due to low complexity: 19762
reads with adapter trimmed: 92364
bases trimmed due to adapters: 4738508

Duplication rate: 76.9895%

Insert size peak (evaluated by paired-end reads): 0

JSON report: MP10k.json
HTML report: MP10k.html

fastp v0.19.6, time used: 591 seconds

# MP10k unk reads
Detecting adapter sequence for read1...
No adapter detected for read1

Detecting adapter sequence for read2...
No adapter detected for read2

Read1 before filtering:
total reads: 52979519
total bases: 7981417831
Q20 bases: 7345057582(92.027%)
Q30 bases: 6701747698(83.9669%)

Read1 after filtering:
total reads: 40033628
total bases: 6017186104
Q20 bases: 5741092250(95.4116%)
Q30 bases: 5322663420(88.4577%)

Read2 before filtering:
total reads: 52979519
total bases: 7982376176
Q20 bases: 6875842548(86.1378%)
Q30 bases: 6039886071(75.6653%)

Read2 after filtering:
total reads: 40033628
total bases: 6014358388
Q20 bases: 5589766113(92.9404%)
Q30 bases: 5047412465(83.9227%)

Filtering result:
reads passed filter: 80067256
reads failed due to low quality: 22907050
reads failed due to too many N: 1380
reads failed due to too short: 2851036
reads failed due to low complexity: 132316
reads with adapter trimmed: 43496
bases trimmed due to adapters: 2799867

Duplication rate: 43.0167%

Insert size peak (evaluated by paired-end reads): 0

JSON report: MP10k_unk.json
HTML report: MP10k_unk.html

fastp v0.19.6, time used: 546 seconds

# MP10k PE reads
Detecting adapter sequence for read1...
No adapter detected for read1

Detecting adapter sequence for read2...
No adapter detected for read2

Read1 before filtering:
total reads: 92595412
total bases: 10339427498
Q20 bases: 9734991913(94.1541%)
Q30 bases: 8989871407(86.9475%)

Read1 after filtering:
total reads: 76806899
total bases: 8989408271
Q20 bases: 8602162029(95.6922%)
Q30 bases: 7994251470(88.9297%)

Read2 before filtering:
total reads: 92595412
total bases: 10456199676
Q20 bases: 9696992802(92.7392%)
Q30 bases: 8841628845(84.5587%)

Read2 aftering filtering:
total reads: 76806899
total bases: 8846079072
Q20 bases: 8373740525(94.6605%)
Q30 bases: 7680890174(86.8282%)

Filtering result:
reads passed filter: 153613798
reads failed due to low quality: 12159456
reads failed due to too many N: 1128
reads failed due to too short: 19079170
reads failed due to low complexity: 337272
reads with adapter trimmed: 22139306
bases trimmed due to adapters: 1220839087

Duplication rate: 45.2146%

Insert size peak (evaluated by paired-end reads): 151

JSON report: MP10k_pe.json
HTML report: MP10k_pe.html

fastp v0.19.6, time used: 776 seconds

# MP10k SE reads
Detecting adapter sequence for read1...
No adapter detected for read1

Read1 before filtering:
total reads: 18119749
total bases: 1257561974
Q20 bases: 1205203768(95.8365%)
Q30 bases: 1126084117(89.545%)

Read1 after filtering:
total reads: 17639144
total bases: 1229482188
Q20 bases: 1187332177(96.5717%)
Q30 bases: 1112826453(90.5118%)

Filtering result:
reads passed filter: 17639144
reads failed due to low quality: 354238
reads failed due to too many N: 50
reads failed due to too short: 125992
reads failed due to low complexity: 325
reads with adapter trimmed: 0
bases trimmed due to adapters: 0

Duplication rate (may be overestimated since this is SE data): 73.236%

JSON report: MP10k_se.json
HTML report: MP10k_se.html

fastp -i /work/frr6/SHAD/NXTRIM/MP10k.se.fastq.gz -o MP10k_se.trimmed.fq.gz --cut_front --cut_tail --cut_window_size=4 --cut_mean_quality=20 --qualified_quality_phred=20 --unqualified_percent_limit=30 --n_base_limit=5 --length_required=50 --low_complexity_filter --complexity_threshold=30 --overrepresentation_analysis --json=MP10k_se.json --html=MP10k_se.html --report_title=MP10k_se --thread=8 
fastp v0.19.6, time used: 94 seconds
```

## Step 3:  Process PE overlaps
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
An example run is shown below.  **_NOTE:_** We have to process both the cleaned PE500 reads and the cleaned PE reads produced from NxTrim above.  Please see the script [pear.sh](./Data/pear.sh) for more details on Job information.
```bash
# Set file names
pe500f="PE500_F.trimmed.fq.gz"
pe500r="PE500_R.trimmed.fq.gz"
mp5kf="MP5k_pe_F.trimmed.fq.gz"
mp5kr="MP5k_pe_R.trimmed.fq.gz"
mp10kf="MP10k_pe_F.trimmed.fq.gz"
mp10kr="MP10k_pe_R.trimmed.fq.gz"

# PE500 reads
pear \
   -o PE500.trimmed.pear \
   -f ${pe500f} \
   -r ${pe500r} \
   -j 16 \
   -k

# From the MP5k reads
pear \
   -o MP5k_pe.trimmed.pear \
   -f ${mp5kf} \
   -r ${mp5kr} \
   -j 16 \
   -k

# From the MP10k reads
pear \
   -o MP10k_pe.trimmed.pear \
   -f ${mp10kf} \
   -r ${mp10kr} \
   -j 16 \
   -k

# Compress reads
gzip PE500.trimmed.pear.assembled.fastq; mv PE500.trimmed.pear.assembled.fastq.gz PE500_se.trimmed.pear.fq.gz
gzip PE500.trimmed.pear.discarded.fastq
gzip PE500.trimmed.pear.unassembled.forward.fastq; mv PE500.trimmed.pear.unassembled.forward.fastq.gz PE500_F.trimmed.pear.fq.gz
gzip PE500.trimmed.pear.unassembled.reverse.fastq; mv PE500.trimmed.pear.unassembled.reverse.fastq.gz PE500_R.trimmed.pear.fq.gz
echo "Finished compressing PE500 reads"

gzip MP5k_pe.trimmed.pear.assembled.fastq; mv MP5k_pe.trimmed.pear.assembled.fastq.gz MP5k_pe_se.trimmed.pear.fq.gz
gzip MP5k_pe.trimmed.pear.discarded.fastq
gzip MP5k_pe.trimmed.pear.unassembled.forward.fastq; mv MP5k_pe.trimmed.pear.unassembled.forward.fastq.gz MP5k_pe_F.trimmed.pear.fq.gz
gzip MP5k_pe.trimmed.pear.unassembled.reverse.fastq; mv MP5k_pe.trimmed.pear.unassembled.reverse.fastq.gz MP5k_pe_R.trimmed.pear.fq.gz
echo "Finished compressing MP5k PE reads"

gzip MP10k_pe.trimmed.pear.assembled.fastq; mv MP10k_pe.trimmed.pear.assembled.fastq.gz MP10k_pe_se.trimmed.pear.fq.gz
gzip MP10k_pe.trimmed.pear.discarded.fastq
gzip MP10k_pe.trimmed.pear.unassembled.forward.fastq; mv MP10k_pe.trimmed.pear.unassembled.forward.fastq.gz MP10k_pe_F.trimmed.pear.fq.gz
gzip MP10k_pe.trimmed.pear.unassembled.reverse.fastq; mv MP10k_pe.trimmed.pear.unassembled.reverse.fastq.gz MP10k_pe_R.trimmed.pear.fq.gz
echo "Finished compressing MP10k PE reads"
```

_Parameters Explained:_
- -o :: output prefix, **does not gzip**
- -f/r :: input forward and reverse read files, recognizes gzip
- -j :: number of threads to use
- -k :: do not reverse-complement the reverse reads in the output file

### Output Summary
_PE500 Reads_
```
 ____  _____    _    ____ 
|  _ \| ____|  / \  |  _ \
| |_) |  _|   / _ \ | |_) |
|  __/| |___ / ___ \|  _ <
|_|   |_____/_/   \_\_| \_\

PEAR v0.9.11 [Nov 5, 2017]

Citation - PEAR: a fast and accurate Illumina Paired-End reAd mergeR
Zhang et al (2014) Bioinformatics 30(5): 614-620 | doi:10.1093/bioinformatics/btt593

Forward reads file.................: /work/frr6/SHAD/FASTP/PE500_F.trimmed.fq.gz
Reverse reads file.................: /work/frr6/SHAD/FASTP/PE500_R.trimmed.fq.gz
PHRED..............................: 33
Using empirical frequencies........: YES
Statistical method.................: OES
Maximum assembly length............: 999999
Minimum assembly length............: 50
p-value............................: 0.010000
Quality score threshold (trimming).: 0
Minimum read size after trimming...: 1
Maximal ratio of uncalled bases....: 1.000000
Minimum overlap....................: 10
Scoring method.....................: Scaled score
Threads............................: 16

Allocating memory..................: 200,000,000 bytes
Computing empirical frequencies....: DONE
  A: 0.277289
  C: 0.224540
  G: 0.224961
  T: 0.273210
  13241024 uncalled bases

Assembled reads ...................: 183,983,972 / 282,679,799 (65.086%)
Discarded reads ...................: 0 / 282,679,799 (0.000%)
Not assembled reads ...............: 98,695,827 / 282,679,799 (34.914%)
Assembled reads file...............: PE500.trimmed.pear.assembled.fastq
Discarded reads file...............: PE500.trimmed.pear.discarded.fastq
Unassembled forward reads file.....: PE500.trimmed.pear.unassembled.forward.fastq
Unassembled reverse reads file.....: PE500.trimmed.pear.unassembled.reverse.fastq
```

_MP5k_pe Reads_
```
 ____  _____    _    ____ 
|  _ \| ____|  / \  |  _ \
| |_) |  _|   / _ \ | |_) |
|  __/| |___ / ___ \|  _ <
|_|   |_____/_/   \_\_| \_\

PEAR v0.9.11 [Nov 5, 2017]

Citation - PEAR: a fast and accurate Illumina Paired-End reAd mergeR
Zhang et al (2014) Bioinformatics 30(5): 614-620 | doi:10.1093/bioinformatics/btt593

Forward reads file.................: /work/frr6/SHAD/FASTP/MP5k_pe_F.trimmed.fq.gz
Reverse reads file.................: /work/frr6/SHAD/FASTP/MP5k_pe_R.trimmed.fq.gz
PHRED..............................: 33
Using empirical frequencies........: YES
Statistical method.................: OES
Maximum assembly length............: 999999
Minimum assembly length............: 50
p-value............................: 0.010000
Quality score threshold (trimming).: 0
Minimum read size after trimming...: 1
Maximal ratio of uncalled bases....: 1.000000
Minimum overlap....................: 10
Scoring method.....................: Scaled score
Threads............................: 16

Allocating memory..................: 200,000,000 bytes
Computing empirical frequencies....: DONE
  A: 0.283777
  C: 0.214987
  G: 0.213886
  T: 0.287350
  3225996 uncalled bases

Assembled reads ...................: 12,346,077 / 79,605,083 (15.509%)
Discarded reads ...................: 0 / 79,605,083 (0.000%)
Not assembled reads ...............: 67,259,006 / 79,605,083 (84.491%)
Assembled reads file...............: MP5k_pe.trimmed.pear.assembled.fastq
Discarded reads file...............: MP5k_pe.trimmed.pear.discarded.fastq
Unassembled forward reads file.....: MP5k_pe.trimmed.pear.unassembled.forward.fastq
Unassembled reverse reads file.....: MP5k_pe.trimmed.pear.unassembled.reverse.fastq
```

_MP10k_pe Reads_
```
 ____  _____    _    ____ 
|  _ \| ____|  / \  |  _ \
| |_) |  _|   / _ \ | |_) |
|  __/| |___ / ___ \|  _ <
|_|   |_____/_/   \_\_| \_\

PEAR v0.9.11 [Nov 5, 2017]

Citation - PEAR: a fast and accurate Illumina Paired-End reAd mergeR
Zhang et al (2014) Bioinformatics 30(5): 614-620 | doi:10.1093/bioinformatics/btt593

Forward reads file.................: /work/frr6/SHAD/FASTP/MP10k_pe_F.trimmed.fq.gz
Reverse reads file.................: /work/frr6/SHAD/FASTP/MP10k_pe_R.trimmed.fq.gz
PHRED..............................: 33
Using empirical frequencies........: YES
Statistical method.................: OES
Maximum assembly length............: 999999
Minimum assembly length............: 50
p-value............................: 0.010000
Quality score threshold (trimming).: 0
Minimum read size after trimming...: 1
Maximal ratio of uncalled bases....: 1.000000
Minimum overlap....................: 10
Scoring method.....................: Scaled score
Threads............................: 16

Allocating memory..................: 200,000,000 bytes
Computing empirical frequencies....: DONE
  A: 0.282901
  C: 0.215660
  G: 0.214794
  T: 0.286645
  3073285 uncalled bases

Assembled reads ...................: 14,781,418 / 76,806,899 (19.245%)
Discarded reads ...................: 0 / 76,806,899 (0.000%)
Not assembled reads ...............: 62,025,481 / 76,806,899 (80.755%)
Assembled reads file...............: MP10k_pe.trimmed.pear.assembled.fastq
Discarded reads file...............: MP10k_pe.trimmed.pear.discarded.fastq
Unassembled forward reads file.....: MP10k_pe.trimmed.pear.unassembled.forward.fastq
Unassembled reverse reads file.....: MP10k_pe.trimmed.pear.unassembled.reverse.fastq
```

## Step 4:  Remove duplicates
The software [clumpify v38.34](https://jgi.doe.gov/data-and-tools/bbtools/bb-tools-user-guide/clumpify-guide/) from the [BBTools](https://jgi.doe.gov/data-and-tools/bbtools/) package was used to remove duplicated reads (both PE or SE). This process removes unnecessary reads that won't contribute ultimately to the assemblies and scaffolding. There is no associated publication.
Alternatively, but not shown below, I have fun [fastuniq vx](https://sourceforge.net/projects/fastuniq/), but I like clumpify much better since it also works on SE reads and can remove optical duplicates as well..  You can see the script [fastuniq.sh](./Data/fastuniq.sh) if this is of interest.

_Installation:_
```bash
# Downloaded bbtools
wget https://sourceforge.net/projects/bbmap/files/BBMap_38.34.tar.gz
tar -zxvf BBMap_38.34.tar.gz
cd bbmap/
ln -s /dscrhome/frr6/PROGRAMS/bbmap/clumpify.sh /dscrhome/frr6/bin/clumpify.sh
```

_Run clumpify_  
An example run is shown below.  **_NOTE:_** We have to process both PE and SE files.  Please see the script [clump.sh](./Data/clump.sh) for more details on Job information.
```bash
# Process all the SE files
./clump.sh SE PE500 PE500_se.trimmed.pear.fq.gz empty
./clump.sh SE MP5k_pe MP5k_pe_se.trimmed.pear.fq.gz empty
./clump.sh SE MP10k_pe MP10k_pe_se.trimmed.pear.fq.gz empty
./clump.sh SE MP5k MP5k_se.trimmed.fq.gz empty
./clump.sh SE MP10k MP10k_se.trimmed.fq.gz empty

# Process all the MP PE files
./clump.sh PE MP5k MP5k_F.trimmed.fq.gz MP5k_R.trimmed.fq.gz
./clump.sh PE MP5k_unk MP5k_unk_F.trimmed.fq.gz MP5k_unk_R.trimmed.fq.gz
./clump.sh PE MP5k_pe MP5k_pe_F.trimmed.pear.fq.gz MP5k_pe_R.trimmed.pear.fq.gz
./clump.sh PE MP10k MP10k_F.trimmed.fq.gz MP10k_R.trimmed.fq.gz
./clump.sh PE MP10k_unk MP10k_unk_F.trimmed.fq.gz MP10k_unk_R.trimmed.fq.gz
./clump.sh PE MP10k_pe MP10k_pe_F.trimmed.pear.fq.gz MP10k_pe_R.trimmed.pear.fq.gz

# Process the PE PE files
./clump.sh PE PE500 PE500_F.trimmed.pear.fq.gz PE500_R.trimmed.pear.fq.gz
```

_clump.sh script_
```bash
#!/bin/bash -l
# Read in file name stem
n=$2
read1=$3
read2=$4

if [ "$1" = 'PE' ]
   then
   echo "Running Clumpify PE mode..."
   clumpify.sh \
      -in=${read1} \
      -in2=${read2} \
      -out=${n}_F.trimmed.deduped.fq.gz \
      -out2=${n}_R.trimmed.deduped.fq.gz \
      dedupe=t \
      containment=f \
      optical=t \
      dupedist=12000
   echo "Finished Clumpify PE mode..."
   elif [ "$1" = 'SE' ]
   then
   echo "Running Clumpify SE mode..."
   clumpify.sh \
      -in=${read1} \
      -out=${n}_se.trimmed.deduped.fq.gz \
      dedupe=t \
      containment=f \
      optical=t \
      dupedist=12000
   echo "Finished Clumpify SE mode..."
   else
   echo "Error:  Must state whether to RUn SE or PE mode!"
fi
```
_Parameters Explained:_
- -in/in2 :: input SE or forward and reverse read files, recognizes gzip
- -out/out2 :: output SE or forward and reverse read files, recognizes gzip
- dedupe=t :: remove duplicates
- containment=f :: turn off containment
- optical=t :: also remove optical duplicates (clusters too close together on flow cell)
- dupedist=12000 :: cluster duplication radius on flow cell, set to 12000 for Novaseq (see manual)

### Output Summary
_PE500 SE Reads_
```
Reads In:            183983972
Clumps Formed:        24043576
Duplicates Found:      5314343
Reads Out:           178669629
Bases Out:         32580881321
Total time: 	5376.857 seconds.
```
_MP5k PE SE Reads_
```
Reads In:             12346077
Clumps Formed:         2776147
Duplicates Found:       343249
Reads Out:            12002828
Bases Out:          1152843265
Total time: 	231.658 seconds.
```
_MP10k PE SE Reads_
```
Reads In:             14781418
Clumps Formed:         2104231
Duplicates Found:       494149
Reads Out:            14287269
Bases Out:          1316546945
Total time: 	224.572 seconds.
```
_MP5k SE Reads_
```
Reads In:             16861797
Clumps Formed:         3281375
Duplicates Found:       571332
Reads Out:            16290465
Bases Out:          1084833963
Total time: 	218.710 seconds.
```
_MP10k SE Reads_
```
Reads In:             17639144
Clumps Formed:         2279245
Duplicates Found:       800526
Reads Out:            16838618
Bases Out:          1174631851
Total time: 	217.946 seconds.
```
_MP5k MP reads_
```
Reads In:            138605294
Clumps Formed:         9704475
Duplicates Found:      3174154
Reads Out:           135431140
Bases Out:         16109764707
Total time: 	1804.868 seconds.
```
_MP5k Unk reads_
```
Reads In:            101028768
Clumps Formed:         9212697
Duplicates Found:      1299408
Reads Out:            99729360
Bases Out:         14988178619
Total time: 	5752.525 seconds.
```
_MP5k PE reads_
```
Reads In:            134518012
Clumps Formed:        10440484
Duplicates Found:      2831958
Reads Out:           131686054
Bases Out:         16051253878
Total time: 	4844.656 seconds.
```
_MP10k MP reads_
```
Reads In:            134859312
Clumps Formed:         6695378
Duplicates Found:      4276242
Reads Out:           130583070
Bases Out:         15392514683
Total time: 	3751.891 seconds.
```
_MP10k Unk reads_
```
Reads In:             80067256
Clumps Formed:         5758195
Duplicates Found:      1513806
Reads Out:            78553450
Bases Out:         11803770125
Total time: 	4356.128 seconds.
```
_MP10k PE reads_
```
Reads In:            124050962
Clumps Formed:         7288410
Duplicates Found:      3684230
Reads Out:           120366732
Bases Out:         14662031651
Total time: 	3916.013 seconds.
```
_PE500 PE Reads_
```
Reads In:            197391654
Clumps Formed:        19586064
Duplicates Found:      2238096
Reads Out:           195153558
Bases Out:         29388195556
Total time: 	10547.929 seconds.
```


## Step 5:  Remove mitochondrial reads
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
This uses [bowtie2 v2.3.0](http://bowtie-bio.sourceforge.net/bowtie2/index.shtml), which has been enabled for mate-pair reads.  Only examples are shown below, please see [remove-mitoPE500.sh](./Data/remove-mitoPE500.sh) script for full code. `bowtie2` is published in:  
Langmead B, Salzberg SL (2012) Fast gapped-read alignment with Bowtie 2. _Nature Methods_ 9(4):357-359. https://doi.org/10.1038/nmeth.1923

```bash
sbatch -J PE500 -o PE500.out -e PE500.err  mito.sh PE PE500 /work/frr6/SHAD/CLUMPIFY/PE500_F.trimmed.deduped.fq.gz /work/frr6/SHAD/CLUMPIFY/PE500_R.trimmed.deduped.fq.gz

sbatch -J PE500_se -o PE500_se.out -e PE500_se.err  mito.sh SE PE500_se /work/frr6/SHAD/CLUMPIFY/PE500_se.trimmed.deduped.fq.gz empty

sbatch -J MP10k -o MP10k.out -e MP10k.err  mito.sh MP MP10k /work/frr6/SHAD/CLUMPIFY/MP10k_F.trimmed.deduped.fq.gz /work/frr6/SHAD/CLUMPIFY/MP10k_R.trimmed.deduped.fq.gz

sbatch -J MP10k_unk -o MP10k_unk.out -e MP10k_unk.err  mito.sh MP MP10k_unk /work/frr6/SHAD/CLUMPIFY/MP10k_unk_F.trimmed.deduped.fq.gz /work/frr6/SHAD/CLUMPIFY/MP10k_unk_R.trimmed.deduped.fq.gz

sbatch -J MP10k_pe -o MP10k_pe.out -e MP10k_pe.err  mito.sh PE MP10k_pe /work/frr6/SHAD/CLUMPIFY/MP10k_pe_F.trimmed.deduped.fq.gz /work/frr6/SHAD/CLUMPIFY/MP10k_pe_R.trimmed.deduped.fq.gz

sbatch -J MP10k_pe_se -o MP10k_pe_se.out -e MP10k_pe_se.err  mito.sh SE MP10k_pe_se /work/frr6/SHAD/CLUMPIFY/MP10k_pe_se.trimmed.deduped.fq.gz empty

sbatch -J MP10k_se -o MP10k_se.out -e MP10k_se.err  mito.sh SE MP10k_se /work/frr6/SHAD/CLUMPIFY/MP10k_se.trimmed.deduped.fq.gz empty
################
sbatch -J MP5k -o MP5k.out -e MP5k.err  mito.sh MP MP5k /work/frr6/SHAD/CLUMPIFY/MP5k_F.trimmed.deduped.fq.gz /work/frr6/SHAD/CLUMPIFY/MP5k_R.trimmed.deduped.fq.gz

sbatch -J MP5k_unk -o MP5k_unk.out -e MP5k_unk.err  mito.sh MP MP5k_unk /work/frr6/SHAD/CLUMPIFY/MP5k_unk_F.trimmed.deduped.fq.gz /work/frr6/SHAD/CLUMPIFY/MP5k_unk_R.trimmed.deduped.fq.gz

sbatch -J MP5k_pe -o MP5k_pe.out -e MP5k_pe.err  mito.sh PE MP5k_pe /work/frr6/SHAD/CLUMPIFY/MP5k_pe_F.trimmed.deduped.fq.gz /work/frr6/SHAD/CLUMPIFY/MP5k_pe_R.trimmed.deduped.fq.gz

sbatch -J MP5k_pe_se -o MP5k_pe_se.out -e MP5k_pe_se.err  mito.sh SE MP5k_pe_se /work/frr6/SHAD/CLUMPIFY/MP5k_pe_se.trimmed.deduped.fq.gz empty

sbatch -J MP5k_se -o MP5k_se.out -e MP5k_se.err  mito.sh SE MP5k_se /work/frr6/SHAD/CLUMPIFY/MP5k_se.trimmed.deduped.fq.gz empty
```

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


_Final Summary of Cleaning:_  

| Name | \# Paired Reads | \# Bases | Q20 bases | Q30 Bases |
| --- | --- | --- | --- | --- |
| PE500 | 280,454,045 | 81,520,790,896 | 96.0% | 89.6% |
| MP5k | 207,677,745 | 62,423,641,430 | 95.2% | 88.1% |
| MP10k | 194,228,811 | 58,364,280,836 | 95.3% | 88.1% |
| __Total__ | 682,360,601 | 202,308,713,162 | 95.5% | 88.7% |
