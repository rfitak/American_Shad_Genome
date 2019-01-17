#!/bin/bash -l
# author: rfitak
#SBATCH -J pear
#SBATCH -o pear.out
#SBATCH -e pear.err
#SBATCH -p biodept
#SBATCH -n 1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=12
#SBATCH -t 36:00:00
#SBATCH --mem-per-cpu=16000
#SBATCH --mail-type=END
#SBATCH --mail-user=rfitak9@gmail.com

cd /work/frr6/SHAD/PEAR

# Merge PE reads produced from NxTrim
zcat \
   /work/frr6/SHAD/NXTRIM/MP5k_R1.pe.fastq.gz \
   /work/frr6/SHAD/NXTRIM/MP10k_R1.pe.fastq.gz \
   | gzip > PE_mp.F.fq.gz
zcat \
   /work/frr6/SHAD/NXTRIM/MP5k_R2.pe.fastq.gz \
   /work/frr6/SHAD/NXTRIM/MP10k_R2.pe.fastq.gz \
   | gzip > PE_mp.R.fq.gz

# Set file names
fwd1="/work/frr6/SHAD/RAW_READS/gDNA_S18_L002_R1_001.fastq.gz"
rev1="/work/frr6/SHAD/RAW_READS/gDNA_S18_L002_R2_001.fastq.gz"
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
