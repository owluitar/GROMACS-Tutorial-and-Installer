#!/bin/bash
mkdir -p tutorial; cd tutorial
mkdir -p bin sources
tutorial=$(pwd)
bin=$tutorial/bin
sources=$tutorial/sources

#Download prerequisites
sudo apt-get install cmake gromacs python
cd sources
git clone https://github.com/agiliopadua/ilff
git clone https://github.com/agiliopadua/fftool
wget https://github.com/m3g/packmol/archive/20.010.tar.gz

tar -xvf 20.010.tar.gz; cd packmol-20.010; make; cp packmol ../bin
cd $sources; rm -rf *20.010*
cd fftool; cp fftool lattice polarizer xyztool $bin; cd $tutorial

