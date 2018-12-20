#!/bin/bash -l
# author: rfitak
#SBATCH -n 1
#SBATCH --nodes=1
#SBATCH -t 6:00:00
#SBATCH --mail-type=END
#SBATCH --mail-user=rfitak9@gmail.com

cd /work/frr6/SHAD/FASTUNIQ

# Read in file name stem
n=$1

echo "Unzipping the trimmed reads..."
zcat ../FASTP/${n}_F.trimmed.fq.gz > ${n}.F.fq
zcat ../FASTP/${n}_R.trimmed.fq.gz > ${n}.R.fq

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

# Remove file
rm -rf ${n}.files ${n}.F.fq ${n}.R.fq

# Compress reads
echo "Compressing files..."
gzip ${n}_F.trimmed.uniq.fq
gzip ${n}_R.trimmed.uniq.fq
echo "Finished compressing files..."

# Get results output
echo "$n trimmed and deduplicated reads Q20..."
seqtk fqchk -q20 <(zcat ${n}_*.trimmed.uniq.fq.gz) | head
echo "$n trimmed and deduplicated reads Q30..."
seqtk fqchk -q30 <(zcat ${n}_*.trimmed.uniq.fq.gz) | head
