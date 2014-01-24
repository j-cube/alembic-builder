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

PKG="db"
PKG_URL="http://download.oracle.com/berkeley-db/db-4.7.25.tar.gz"
PKG_FILENAME="db-4.7.25.tar.gz"
PKG_DIR="db-4.7.25"

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

cd build_unix
../dist/configure --prefix=${TGT} \
  --includedir=${TGT}/include/db4.7 --libdir=${TGT}/lib/db4.7 \
  --docdir=${TGT}/db4.7/docs --enable-compat185 --enable-cxx \
  --enable-shared --enable-static --with-pic 2>&1 | tee ${PKG_LOG_PFX}-configure.log
make 2>&1 | tee ${PKG_LOG_PFX}-make.log
#make test 2>&1 | tee ${PKG_LOG_PFX}-make-test.log
make install 2>&1 | tee ${PKG_LOG_PFX}-make-install.log

date "+%Y/%m/%d %H:%M:%S" > ${TOP_BUILD_DIR}/.built.${PKG}

cd ${TOP_BUILD_DIR}
echo "${PKG} built."
