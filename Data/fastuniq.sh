#!/bin/bash -l
# author: rfitak
#SBATCH -p common-large
#SBATCH -n 1
#SBATCH --nodes=1
#SBATCH -t 6:00:00
#SBATCH --mem=235G
#SBATCH --mail-type=END
#SBATCH --mail-user=rfitak9@gmail.com

cd /datacommons/netscratch/frr6/SHAD_GENOME

# Read in file name stem
n=$1

# Uncompress reads
echo "Getting initial MD5 tags..."
# a=$(md5sum ${n}_F.trimmed.fq.gz)
# b=$(md5sum ${n}_R.trimmed.fq.gz)

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

# Remove file
rm -rf ${n}.files ${n}.F.fq ${n}.R.fq

# Compress reads
echo "Compressing files..."
gzip ${n}_F.trimmed.uniq.fq
gzip ${n}_R.trimmed.uniq.fq
# gzip ${n}_F.trimmed.fq
# gzip ${n}_R.trimmed.fq
echo "Finished compressing files..."

# Check MD5
#c=$(md5sum ${n}_F.trimmed.fq.gz)
#d=$(md5sum ${n}_R.trimmed.fq.gz)
#if [ "$a" = "$c" ]
#   then
#   echo "Forward reads MD5 check out good!"
#   else
#   echo "Forward reads MD5 ERROR!"
#fi
#if [ "$b" = "$d" ]
#   then
#   echo "Reverse reads MD5 check out good!"
#   else
#   echo "Reverse reads MD5 ERROR!"
#fi

