#!/bin/bash -l
# author: rfitak
#SBATCH -J pear
#SBATCH -o pear.out
#SBATCH -e pear.err
#SBATCH -p biodept
#SBATCH -n 1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH -t 48:00:00
#SBATCH --mem-per-cpu=12000
#SBATCH --mail-type=END
#SBATCH --mail-user=rfitak9@gmail.com

cd /work/frr6/SHAD/PEAR

# Set file names
pe500f="/work/frr6/SHAD/FASTP/PE500_F.trimmed.fq.gz"
pe500r="/work/frr6/SHAD/FASTP/PE500_R.trimmed.fq.gz"
mp5kf="/work/frr6/SHAD/FASTP/MP5k_pe_F.trimmed.fq.gz"
mp5kr="/work/frr6/SHAD/FASTP/MP5k_pe_R.trimmed.fq.gz"
mp10kf="/work/frr6/SHAD/FASTP/MP10k_pe_F.trimmed.fq.gz"
mp10kr="/work/frr6/SHAD/FASTP/MP10k_pe_R.trimmed.fq.gz"

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
