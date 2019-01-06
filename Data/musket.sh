#!/bin/bash -l
# author: rfitak
#SBATCH -J musket
#SBATCH -o musket.out
#SBATCH -e musket.err
#SBATCH -p biodept
#SBATCH -n 1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=12
#SBATCH -t 60:00:00
#SBATCH --mem=235G
#SBATCH --mail-type=END
#SBATCH --mail-user=rfitak9@gmail.com

cd /work/frr6/SHAD/MUSKET

# Run Musket
echo "Running musket..."

musket \
   -k 21 536870912 \
   -p 12 \
   -omulti corrected \
   -inorder \
   -zlib 1 \
   -lowercase \
   ../MITO/PE500_F.trimmed.uniq.noMito.fq.gz \
   ../MITO/PE500_R.trimmed.uniq.noMito.fq.gz \
   ../MITO/MP5k_F.trimmed.uniq.unj.noMito.fq.gz \
   ../MITO/MP5k_R.trimmed.uniq.unj.noMito.fq.gz \
   ../MITO/MP10k_F.trimmed.uniq.unj.noMito.fq.gz \
   ../MITO/MP10k_R.trimmed.uniq.unj.noMito.fq.gz

# Change file names
mv corrected.0 PE500_F.trimmed.uniq.noMito.corrected.fq.gz
mv corrected.1 PE500_R.trimmed.uniq.noMito.corrected.fq.gz
mv corrected.2 MP5k_F.trimmed.uniq.unj.noMito.corrected.fq.gz
mv corrected.3 MP5k_R.trimmed.uniq.unj.noMito.corrected.fq.gz
mv corrected.4 MP10k_F.trimmed.uniq.unj.noMito.corrected.fq.gz
mv corrected.5 MP10k_R.trimmed.uniq.unj.noMito.corrected.fq.gz

# Count corrected bases
pe500=$(zcat PE500_F.trimmed.uniq.noMito.corrected.fq.gz PE500_R.trimmed.uniq.noMito.corrected.fq.gz | \
   seqtk seq -l0 -A | \
   grep -v "^>" | \
   grep -oc "[atcg]")
echo "Corrected $pe500 bases in PE500 reads"

mp5k=$(zcat MP5k_F.trimmed.uniq.unj.noMito.corrected.fq.gz MP5k_R.trimmed.uniq.unj.noMito.corrected.fq.gz | \
   seqtk seq -l0 -A | \
   grep -v "^>" | \
   grep -oc "[atcg]")
echo "Corrected $mp5k bases in MP5k reads"

mp10k=$(zcat MP10k_F.trimmed.uniq.unj.noMito.corrected.fq.gz MP10k_R.trimmed.uniq.unj.noMito.corrected.fq.gz | \
   seqtk seq -l0 -A | \
   grep -v "^>" | \
   grep -oc "[atcg]")
echo "Corrected $mp10k bases in MP10k reads"

# Get seqtk output
echo "PE500 corrected reads Q20..."
seqtk fqchk -q20 <(zcat PE500_*.trimmed.uniq.noMito.corrected.fq.gz) | head
echo "PE500 corrected reads Q30..."
seqtk fqchk -q30 <(zcat PE500_*.trimmed.uniq.noMito.corrected.fq.gz) | head

echo "MP5k corrected reads Q20..."
seqtk fqchk -q20 <(zcat MP5k_*.trimmed.uniq.unj.noMito.corrected.fq.gz) | head
echo "MP5k corrected reads Q30..."
seqtk fqchk -q30 <(zcat MP5k_*.trimmed.uniq.unj.noMito.corrected.fq.gz) | head

echo "MP10k corrected reads Q20..."
seqtk fqchk -q20 <(zcat MP10k_*.trimmed.uniq.unj.noMito.corrected.fq.gz) | head
echo "MP10k corrected reads Q30..."
seqtk fqchk -q30 <(zcat MP10k_*.trimmed.uniq.unj.noMito.corrected.fq.gz) | head

echo "All corrected reads Q20..."
seqtk fqchk -q20 <(zcat *.corrected.fq.gz) | head
echo "All corrected reads Q30..."
seqtk fqchk -q30 <(zcat *.corrected.fq.gz) | head 
