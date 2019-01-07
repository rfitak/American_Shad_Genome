# Assembling the Genome
The steps to build the _de novo_ genome assembly include:
- Estimating the best _k_-mer length for the assembly
  - Program: KmerGenie
- Performing the assembly
  - Program: Abyss v2.1.5
- Assembly clean-up and checking
  - Programs: xxx

### Step 1:  Estimating _k_-mer length using KmerGenie

Prior to assembly, the first step is to select an appropriate _k_-mer length to use for the assembly.  Rather than running multiple assemblies at different vlaues for _k_, we will use KmerGenie.




### Assembly with Abyss 2.1.5

```bash
# Install google sparsehash
git clone https://github.com/sparsehash/sparsehash.git
cd sparsehash/
./configure --prefix=/dscrhome/frr6/bin/
make
make install

# Install Abyss v2.1.5
wget http://www.bcgsc.ca/platform/bioinfo/software/abyss/releases/2.1.5/abyss-2.1.5.tar.gz
tar -zxvf abyss-2.1.5.tar.gz
cd abyss-2.1.5/
./configure --prefix=/dscrhome/frr6/bin/ --with-sparsehash=/dscrhome/frr6/bin
make
make install

```
