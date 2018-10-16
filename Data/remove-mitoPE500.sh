#!/bin/bash -l
# author: rfitak
#SBATCH -J PE500
#SBATCH -o PE500rmMito.out
#SBATCH -e PE500rmMito.err
#SBATCH -p biodept
#SBATCH -n 1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH -t 12:00:00
#SBATCH --mem-per-cpu=8000
#SBATCH --mail-type=END
#SBATCH --mail-user=rfitak9@gmail.com

cd /datacommons/netscratch/frr6/SHAD_GENOME
name="PE500"

# Do Mapping for PE reads
bowtie2 \
   --phred33 \
   -q \
   --very-sensitive \
   --minins 0 \
   --maxins 1000 \
   --fr \
   --threads 8 \
   --reorder \
   -x Asap_mito \
   -1 ${name}_F.trimmed.uniq.fq.gz \
   -2 ${name}_R.trimmed.uniq.fq.gz | \
   samtools1.3 view -b -F 2 | \
   samtools1.3 sort -T ${name}.tmp -n -O bam | \
   bedtools bamtofastq -i - -fq ${name}_F.trimmed.uniq.noMito.fq -fq2 ${name}_R.trimmed.uniq.noMito.fq

# Get Stats
seqtk fqchk -q20 <(cat ${name}_*.trimmed.uniq.noMito.fq) | head
seqtk fqchk -q30 <(cat ${name}_*.trimmed.uniq.noMito.fq) | head

# Compress the resulting reads
gzip ${name}_F.trimmed.uniq.noMito.fq
gzip ${name}_R.trimmed.uniq.noMito.fq

