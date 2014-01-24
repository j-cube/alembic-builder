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

PKG="pyilmbase"
PKG_URL="https://github.com/downloads/openexr/openexr/pyilmbase-1.0.0-v1.7.tar.gz"
PKG_FILENAME="pyilmbase-1.0.0-v1.7.tar.gz"
PKG_DIR="pyilmbase-1.0.0"

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
tar xfz $PKG_FILENAME

cd $PKG_DIR

cat ${TOP_BUILD_DIR}/pyilmbase-1.0.0-unresolved-symbols-v2.patch | patch -p1

export CPPFLAGS="-I/opt/jcube/lib/python2.6/site-packages/numpy/core/include/"

./configure --prefix=${TGT} \
  --with-ilmbase-prefix=${TGT} \
  --with-boost-include-dir=${TGT}/include/boost-1_48 \
  --with-boost-lib-dir=${TGT}/lib \
  --with-boost-python-libname=boost_python-gcc46-mt-1_48 2>&1 | tee ${PKG_LOG_PFX}-configure.log
make 2>&1 | tee ${PKG_LOG_PFX}-make.log
make install 2>&1 | tee ${PKG_LOG_PFX}-make-install.log

date "+%Y/%m/%d %H:%M:%S" > ${TOP_BUILD_DIR}/.built.${PKG}

cd ${TOP_BUILD_DIR}
echo "${PKG} built."
