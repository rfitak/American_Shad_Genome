# Raw Sequencing Read Cleaning
This section will start with the raw sequencing data and perform a series a cleaning steps to prepare the sequences for the genome assembly.  The various steps include:
1.  Filtering low-quality reads, Trimming low-quality bases, adapter identification and removal
    - Program: [fastp](https://github.com/OpenGene/fastp)
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
| Name | Type | Insert Size | \# Paired Reads | \# Bases | Q20 bases | Q30 Bases |
| --- | --- | --- | --- | --- | --- | --- |
| PE500 | 151 bp; Paired-end | TBD | 313,465,270 | 94,666,511,540 | 88.2% | 81.4% |
| MP5k | 151 bp; Mate-pair | 5-7 kb | 226,692,460 | 68,461,122,920 | 93.1% | 85.3% |
| MP10k | 151 bp; Mate-pair | 10-12 kb | 223,358,676 | 67,454,320,152 | 92.8% | 85.0% |
| Total | n/a | n/a | 763,516,406 | 230,581,954,612 | n/a | n/a |


## Step 1:  Read trimming and filtering
Here the new software [fastp v0.19.4](https://github.com/OpenGene/fastp) was used. It combines a QC (Similar to FastQC) along with various trimming and filtering functions. The publication can be found here:  
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
   -i ${fwd} \
   -I ${rev} \
   -o ${name}_F.trimmed.fq.gz \
   -O ${name}_R.trimmed.fq.gz \
   -n 5 \
   -q 30 \
   -u 30 \
   --length_required=100 \
   --low_complexity_filter \
   --complexity_threshold=20 \
   --cut_by_quality3 \
   --cut_by_quality5 \
   --cut_window_size=4 \
   --cut_mean_quality=30 \
   --trim_poly_g \
   --poly_g_min_len=10 \
   --overrepresentation_analysis \
   --json=${name}.json \
   --html=${name}.html \
   --report_title="$name" \
   --thread=8
```
_Parameters Explained:_
- xxxx
- xxxx
- xxxx

_See the Output HTML Files:_
- [PE500](./Data/PE500.pdf)
- [MP5k](./Data/MP5k.pdf)
- [MP10k](./Data/MP10k.pdf)

_Summary of Results After Cleaning:_  
| Name | \# Paired Reads | \# Bases | Q20 bases | Q30 Bases |
| --- | --- | --- | --- | --- |
| PE500 | 239,477,910 | 70.1 G | 97.6% | 92.4% |
| MP5k | 178,871,091 | 53.6 G | 97.1% | 91.2% |
| MP10k | 167,372,392 | 50.1 G | 97.1% | 91.2% |
| Total | 585,721,393 | 173.8 G | n/a | n/a |
