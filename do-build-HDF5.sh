#!/bin/bash

set -e

if [ -z "${BUILD_SETUP_READY}" ] ; then
  . env-build-setup.sh
fi

if [ -z "${TGT}" ] ; then
  echo "ERROR: TGT variable not set."
  exit 1
fi

if [ ! -e ${TGT} ] ; then
  echo "ERROR: target directory ${TGT} doesn't exist."
  exit 1
fi

PKG="hdf5"
PKG_URL="http://www.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8.9/src/hdf5-1.8.9.tar.bz2"
PKG_FILENAME="hdf5-1.8.9.tar.bz2"
PKG_DIR="hdf5-1.8.9"

cd ${TOP_BUILD_DIR}
if [ -e ${TOP_BUILD_DIR}/.built.${PKG} ] ; then
  echo "${PKG} already built"
  exit 0
fi

PKG_LOG_PFX="${LOG_PREFIX}${PKG}"

if [ ! -e $PKG_FILENAME ] ; then
  wget --content-disposition $PKG_URL
fi

if [ -e $PKG_DIR ] ; then
  rm -rf $PKG_DIR
fi
tar xfj $PKG_FILENAME

cd $PKG_DIR

# IMPORTANT:
# read ${TOP_BUILD_DIR}/Alembic/doc/HDF5-howtobuild.txt

if [ ! -e cmake_patch.txt ] ; then
  wget --content-disposition http://www.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8.9/src/cmake_patch.txt
fi

cat cmake_patch.txt | patch -p0

if [ "${TARGET_64}" = "yes" ] ; then
  export CFLAGS="-m64 -fPIC"
else
  export CFLAGS="-fPIC"
fi

./configure --prefix=${TGT} \
  --with-pic --disable-shared \
  --enable-production --disable-debug \
  --enable-threadsafe --with-pthread=/usr/include,/usr/lib 2>&1 | tee ${PKG_LOG_PFX}-configure.log
make 2>&1 | tee ${PKG_LOG_PFX}-make.log
make install 2>&1 | tee ${PKG_LOG_PFX}-make-install.log

date "+%Y/%m/%d %H:%M:%S" > ${TOP_BUILD_DIR}/.built.${PKG}

cd ${TOP_BUILD_DIR}
echo "${PKG} built."
