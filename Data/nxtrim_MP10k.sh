#!/bin/bash -l
# author: rfitak
#SBATCH -J nxtrim10k
#SBATCH -o nxtrim10k.out
#SBATCH -e nxtrim10k.err
#SBATCH -p common
#SBATCH -n 1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH -t 36:00:00
#SBATCH --mem-per-cpu=16000
#SBATCH --mail-type=END
#SBATCH --mail-user=rfitak9@gmail.com

cd /work/frr6/SHAD/NXTRIM
fwd="/work/frr6/SHAD/RAW_READS/10-12kb_S17_L002_R1_001.fastq.gz"
rev="/work/frr6/SHAD/RAW_READS/10-12kb_S17_L002_R2_001.fastq.gz"
name="MP10k"

# Run nxtrim
nxtrim \
   -1 ${fwd} \
   -2 ${rev} \
   -O ${name} \
   --rf \
   --separate \
   -a \
   -l 50

# Get stats
#echo "MP5K trimmed reads Q20..."
#seqtk fqchk -q20 <(zcat ${name}_*.trimmed.fq.gz) | head
#echo "MP5K trimmed reads Q30..."
#seqtk fqchk -q30 <(zcat ${name}_*.trimmed.fq.gz) | head
