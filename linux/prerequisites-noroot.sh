#!/bin/bash
#Initial Setup
mkdir -p tutorial; cd tutorial
mkdir -p bin sources programs
programs=$(pwd)/programs
bin=$(pwd)/bin
sources=$(pwd)/sources
ncores=$(nproc)
export PATH=$bin:$PATH

#Download all the prerequisites
cd $sources
wget https://www.openssl.org/source/old/1.1.1/openssl-1.1.1f.tar.gz
wget https://github.com/Kitware/CMake/releases/download/v3.17.3/cmake-3.17.3.tar.gz
wget http://ftp.gromacs.org/pub/gromacs/gromacs-2018.1.tar.gz
wget https://www.python.org/ftp/python/2.7.14/Python-2.7.14.tgz
wget https://github.com/m3g/packmol/archive/20.010.tar.gz
git clone https://github.com/agiliopadua/ilff
git clone https://github.com/agiliopadua/fftool

#Packmol Install
tar -xvf 20.010.tar.gz; cd packmol-20.010; make; cp packmol $bin
cd $sources; rm -rf packmol-20.010

#OpenSSL Install (Prerequisite for CMake)
tar -xvf openssl-1.1.1f.tar.gz; cd openssl-1.1.1f
./Configure --prefix=$programs/openssl/1.1.1f linux-x86_64
make -j $ncores; make install
cd $sources; rm -rf openssl-1.1.1f

#CMake Install
tar -xvf cmake-3.17.3.tar.gz; cd cmake-3.17.3; 
export CPLUS_INCLUDE_PATH=$programs/openssl/1.1.1f/include
./configure --prefix=$programs/cmake/3.17.3 --parallel=$ncores
make -j $ncores; make install; ln -s $programs/cmake/3.17.3/bin/cmake $bin/cmake
export CMAKE_ROOT=$programs/cmake/3.17.3
cd $sources; rm -rf cmake-3.17.3

#Python Install
tar -xvf Python-2.7.14.tgz; cd Python-2.7.14
./configure --prefix=$programs/python/2.7.14 
make -j $ncores; make install
cd $sources; rm -rf Python-2.7.14

#FFTool Install
cd fftool; cp fftool lattice polarizer xyztool $bin;
cd $sources

#Gromacs Install
tar -xvf gromacs-2018.1.tar.gz; cd gromacs-2018.1
mkdir build; cd build;
cmake .. -DGMX_GPU=OFF -DGMX_BUILD_OWN_FFTW=ON -DREGRESSIONTEST_DOWNLOAD=ON -DCMAKE_INSTALL_PREFIX=$programs/gromacs/2018.1
make -j $ncores;
make check |& tee check-log
cat check-log | grep "failed"
failed=$(cat check-log | grep "failed" | awk '{print $4}')
if [ failed -ne 0 ]; then 
{ 
 while true; do
    read -p "There were failed tests for GROMACS. Do you still wish to install this program?" yn
    case $yn in
	[Yy]* ) make install; echo "Congrats! You successfully installed GROMACS! (But it had failed tests :( )"; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
    done
} else
make install
cd $tutorial;ln -s $programs/gromacs/2018.1/bin/GMXRC.bash
echo "Congrats! You successfully installed GROMACS!"
echo "In order to use your new GROMACS installation,"
echo "type \"source GMXRC.bash\""
fi


