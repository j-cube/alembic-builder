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

PKG="bzip2"
PKG_URL="http://www.bzip.org/1.0.6/bzip2-1.0.6.tar.gz"
PKG_FILENAME="bzip2-1.0.6.tar.gz"
PKG_DIR="bzip2-1.0.6"

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

make CC="gcc -fPIC" 2>&1 | tee ${PKG_LOG_PFX}-make.log
#make test 2>&1 | tee ${PKG_LOG_PFX}-make-test.log
make install PREFIX=${TGT} 2>&1 | tee ${PKG_LOG_PFX}-make-install.log
mkdir -p ${TGT}/share/man/man1/
mv ${TGT}/man/man1/* ${TGT}/share/man/man1/
rmdir ${TGT}/man/man1 ${TGT}/man


date "+%Y/%m/%d %H:%M:%S" > ${TOP_BUILD_DIR}/.built.${PKG}

cd ${TOP_BUILD_DIR}
echo "${PKG} built."
