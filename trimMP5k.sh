#!/bin/bash -l
# author: rfitak
#SBATCH -J trimMP5k
#SBATCH -o trimMP5k.out
#SBATCH -e trimMP5k.err
#SBATCH -p biodept
#SBATCH -n 1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH -t 3:00:00
#SBATCH --mem-per-cpu=8000
#SBATCH --mail-type=END
#SBATCH --mail-user=rfitak9@gmail.com

cd /datacommons/netscratch/frr6/SHAD_GENOME
fwd="5-7kb_S16_L002_R1_001.fastq.gz"
rev="5-7kb_S16_L002_R2_001.fastq.gz"
name="MP5k"

fastp \
   -i ${fwd} \
   -I ${rev} \
   -o ${name}_F.trimmed.fq.gz \
   -O ${name}_R.trimmed.fq.gz \
   -n 5 \
   -q 30 \
   -u 30 \
   --length_required=100 \
   --low_complexity_filter \
   --complexity_threshold=20 \
   --cut_by_quality3 \
   --cut_by_quality5 \
   --cut_window_size=4 \
   --cut_mean_quality=30 \
   --trim_poly_g \
   --poly_g_min_len=10 \
   --overrepresentation_analysis \
   --json=${name}.json \
   --html=${name}.html \
   --report_title="$name" \
   --thread=8
