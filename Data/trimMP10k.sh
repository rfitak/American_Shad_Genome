#!/bin/bash -l
# author: rfitak
#SBATCH -J trimMP10k
#SBATCH -o trimMP10k.out
#SBATCH -e trimMP10k.err
#SBATCH -p biodept
#SBATCH -n 1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH -t 3:00:00
#SBATCH --mem-per-cpu=8000
#SBATCH --mail-type=END
#SBATCH --mail-user=rfitak9@gmail.com

cd /work/frr6/SHAD/FASTP
fwd="10-12kb_S17_L002_R1_001.fastq.gz"
rev="10-12kb_S17_L002_R2_001.fastq.gz"
name="MP10k"

fastp \
   -i ../RAW_READS/${fwd} \
   -I ../RAW_READS/${rev} \
   -o ${name}_F.trimmed.fq.gz \
   -O ${name}_R.trimmed.fq.gz \
   -n 5 \
   -q 20 \
   -u 30 \
   --detect_adapter_for_pe \
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

echo "MP10k trimmed reads Q20..."
seqtk fqchk -q20 <(zcat ${name}_*.trimmed.fq.gz) | head
echo "MP10k trimmed reads Q30..."
seqtk fqchk -q30 <(zcat ${name}_*.trimmed.fq.gz) | head
