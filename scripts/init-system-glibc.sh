#!/bin/bash
set -euxo pipefail

## gcc 9.3.0 & glibc 2.32 & make 4.3 (for conda install)
### gcc
gcc_home=/home/coding/gcc
rm -rf $gcc_home
mkdir -p $gcc_home

pushd $gcc_home
curl -LO https://mirrors.tuna.tsinghua.edu.cn/gnu/gcc/gcc-9.3.0/gcc-9.3.0.tar.gz
tar -xvf gcc-9.3.0.tar.gz
cd gcc-9.3.0

sed -i "s/ftp:\/\/gcc.gnu.org\/pub\/gcc\/infrastructure/https:\/\/mirrors.tuna.tsinghua.edu.cn\/gnu/g" ./contrib/download_prerequisites
sed -i "s/\${base_url}\${ar}/\${base_url}\`echo \${ar} | sed 's\/-\.\*\/\/g'\`\/\${ar}/g" ./contrib/download_prerequisites
sed -i "s/\${fetch}/\${fetch} --no-check-certificate/g" ./contrib/download_prerequisites
./contrib/download_prerequisites --no-graphite
mkdir -p build
cd build
../configure -prefix=/usr --enable-checking=release --enable-languages=c,c++ --disable-multilib 
make && make install
popd
rm -rf $gcc_home

### make
make_home=/home/coding/make
rm -rf $make_home
mkdir -p $make_home

pushd $make_home
curl -LO https://mirrors.tuna.tsinghua.edu.cn/gnu/make/make-4.3.tar.gz
tar -xzvf make-4.3.tar.gz 
cd make-4.3
mkdir build
cd build
../configure --prefix=/usr
make && make install
popd
rm -rf $make_home

### glibc
yum -y install bison
yum -y install python3

glibc_home=/home/coding/glibc
rm -rf $glibc_home
mkdir -p $glibc_home

pushd $glibc_home
curl -LO https://mirrors.tuna.tsinghua.edu.cn/gnu/glibc/glibc-2.32.tar.gz
tar -xzvf glibc-2.32.tar.gz
cd glibc-2.32
mkdir build
cd build
../configure --prefix=/usr
sed -i 's/name ne "thread_db"/name ne "thread_db"\n\t\&\& \$name ne "nss_test2"/g' ../scripts/test-installation.pl
make && make install
popd
rm -rf $glibc_home