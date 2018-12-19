#!/bin/bash -l
# author: rfitak
#SBATCH -J trimPE
#SBATCH -o trimPE.out
#SBATCH -e trimPE.err
#SBATCH -p biodept
#SBATCH -n 1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH -t 3:00:00
#SBATCH --mem-per-cpu=8000
#SBATCH --mail-type=END
#SBATCH --mail-user=rfitak9@gmail.com

cd /work/frr6/SHAD/FASTP
fwd="gDNA_S18_L002_R1_001.fastq.gz"
rev="gDNA_S18_L002_R2_001.fastq.gz"
name="PE500"

fastp \
   -i ../RAW_READS/${fwd} \
   -I ../RAW_READS/${rev} \
   -o ${name}_F.trimmed.fq.gz \
   -O ${name}_R.trimmed.fq.gz \
   -n 5 \
   -q 20 \
   -u 30 \
   --length_required=70 \
   --low_complexity_filter \
   --complexity_threshold=20 \
   --cut_by_quality3 \
   --cut_by_quality5 \
   --cut_window_size=4 \
   --cut_mean_quality=20 \
   --trim_poly_g \
   --poly_g_min_len=10 \
   --overrepresentation_analysis \
   --json=${name}.json \
   --html=${name}.html \
   --report_title="$name" \
   --thread=8

echo "PE500 trimmed reads Q20..."
seqtk fqchk -q20 <(zcat PE500_*.trimmed.fq.gz) | head
echo "PE500 trimmed reads Q30..."
seqtk fqchk -q30 <(zcat PE500_*.trimmed.fq.gz) | head

