#!/bin/bash -l
# author: rfitak
#SBATCH -J flash
#SBATCH -o flash.out
#SBATCH -e flash.err
#SBATCH -p biodept
#SBATCH -n 1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=12
#SBATCH -t 36:00:00
#SBATCH --mem-per-cpu=16000
#SBATCH --mail-type=END
#SBATCH --mail-user=rfitak9@gmail.com

cd /work/frr6/SHAD/FLASH

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
flash \
   -o PE500.flash \
   -M 100 \
   -t 12 \
   -z \
   ${fwd1} \
   ${rev1}

# From the MP reads
flash \
   -o PE_mp.flash \
   -M 100 \
   -t 12 \
   -z \
   ${fwd2} \
   ${rev2}
