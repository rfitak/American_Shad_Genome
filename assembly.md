# Assembly with Abyss 2.1.5

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
