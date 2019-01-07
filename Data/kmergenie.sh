#!/bin/bash -l
# author: rfitak
#SBATCH -J kmergenie
#SBATCH -o kmergenie.out
#SBATCH -e kmergenie.err
#SBATCH -p biodept
#SBATCH -n 1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=12
#SBATCH -t 24:00:00
#SBATCH --mem=235G
#SBATCH --mail-type=END
#SBATCH --mail-user=rfitak9@gmail.com

cd /work/frr6/SHAD/KMER_GENIE

# Run KmerGenie
kmergenie \
   reads.list \
   --diploid \
   -t 12 \
   -o kmer
