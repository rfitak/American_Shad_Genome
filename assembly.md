# Assembling the Genome
The steps to build the _de novo_ genome assembly include:
1. Estimating the best _k_-mer length for the assembly
    - Program: [KmerGenie v1.7051](http://kmergenie.bx.psu.edu)
2. Performing the assembly
    - Program: [Abyss v2.1.5](http://www.bcgsc.ca/platform/bioinfo/software/abyss)
3. Assembly clean-up and checking
    - Programs: xxx

## Step 1:  Estimating _k_-mer length
Prior to assembly, the first step is to select an appropriate _k_-mer length to use for the assembly.  Rather than running multiple assemblies at different vlaues for _k_, we will use the software [KmerGenie v1.7051](http://kmergenie.bx.psu.edu).
The publication can be found here:  
Chikhi R and Medvedev P (2014) Informed and automated k-mer size selection for genome assembly. _Bioinformatics_ 30(1): 31–37. https://doi.org/10.1093/bioinformatics/btt310

_Installation:_
```bash
# Install KmerGenie
wget http://kmergenie.bx.psu.edu/kmergenie-1.7051.tar.gz
tar -zxvf kmergenie-1.7051.tar.gz
cd kmergenie-1.7051/
make
```

_Run kmergenie_  
Please see the script [kmergenie.sh](./Data/kmergenie.sh) for more details on Job information. According to KmerGenie, only reads used by the assembler, not those for scaffolding (i.e. mate pairs), should be used.
```bash
# Make list of sequence files
ls /work/frr6/SHAD/MUSKET/PE500*.fq.gz > reads.list

# Run kmergenie
kmergenie \
   reads.list \
   --diploid \
   -t 12 \
   -o kmer
```
_Parameters Explained:_
- reads.list :: file with list of reads files to include, one per line. (does/not recognize gzipped files)
- --diploid :: diploid organism
- -t :: number of cpus to use
- -o :: output file prefix

_See the Output HTML/PDF Files:_
- [kmergenie_report](./Data/kmergenie_report.pdf)

_Summary of Results:_
KmerGenie reported:
1.  An estimated best ___k_=97__
2.  An estimated genome size of __842,670,695 bp__
3.  See the plot below:
![KmerGenie plot](./images/kmer2.dat.png)


## Step 2: Assembly with Abyss 2.1.5
From the website:
"ABySS is a de novo, parallel, paired-end sequence assembler that is designed for short reads. The single-processor version is useful for assembling genomes up to 100 Mbases in size. The parallel version is implemented using MPI and is capable of assembling larger genomes."  I have used it previously to assemble the dromedary and Florida panther genomes. The publications can be found here:
- Jackman SD, Vandervalk BP, Mohamadi H, Chu J, Yeo S, Hammond SA, Jahesh G, Khan H, Coombe L, Warren RL, and Birol I (2017) ABySS 2.0: resource-efficient assembly of large genomes using a Bloom filter. _Genome Research_ 27: 768-777. https://doi.org/10.1101/gr.214346.116
- Simpson JT, Wong K, Jackman SD, Schein JE, Jones SJ, Birol I. (2009) ABySS: A parallel assembler for short read sequence data. _Genome Research_ 19: 1117-1123. https://doi.org/10.1101/gr.089532.108

_Installation:_
```bash
# Install google sparsehash
git clone https://github.com/sparsehash/sparsehash.git
cd sparsehash/
./configure --prefix=/dscrhome/frr6/bin/
make
make install

# Install Abyss v2.1.5
wget http://www.bcgsc.ca/platform/bioinfo/software/abyss/releases/2.1.5/abyss-2.1.5.tar.gz
tar -zxvf abyss-2.1.5.tar.gz
cd abyss-2.1.5/
./configure --prefix=/dscrhome/frr6/bin/ --with-sparsehash=/dscrhome/frr6/bin
make
make install
```

_Run Abyss_  
Please see the script [abyss.sh](./Data/abyss.sh) for more details on Job information.
```bash
# Setup TMPDIR
export TMPDIR=/work/frr6

# First, make a dry run to just print out the complete list of commands:
abyss-pe \
   k=75 \
   G=1300000000 \
   -n \
   v=-v \
   name=Asap \
   lib='PE500' \
   mp='MP5k MP10k' \
   PE500='PE500_F.trimmed.uniq.noMito.corrected.fq.gz PE500_R.trimmed.uniq.noMito.corrected.fq.gz' \
   MP5k='MP5k_F.trimmed.uniq.unj.noMito.corrected.fq.gz MP5k_R.trimmed.uniq.unj.noMito.corrected.fq.gz' \
   MP10k='MP10k_F.trimmed.uniq.unj.noMito.corrected.fq.gz MP10k_R.trimmed.uniq.unj.noMito.corrected.fq.gz'

```
_Parameters Explained:_
- k :: _k_-mer length for the assembly
- G :: genome size estimate for NG50, 1.3 pg (~1.3 Gb) for _A. sapidissima_
    - Taken from [genomesize.com](http://www.genomesize.com/result_species.php?id=2065)
    - Hinegardner R and Rosen DE (1972) Cellular DNA Content and the Evolution of Teleostean Fishes. _American Naturalist_ 106(951): 621-644. https://www.jstor.org/stable/2459724
- -n :: print out the complete list of commands to run (dry run)
- v=-v :: verbose output
- name :: name of assembly
- lib :: name of PE library
- mp :: name(s) of mate-pair libraries
- ... :: lists of the files in each library






