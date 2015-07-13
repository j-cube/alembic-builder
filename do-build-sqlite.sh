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

PKG="sqlite"
PKG_URL="http://www.sqlite.org/cgi/src/tarball/SQLite-c7c6050e.tar.gz?uuid=c7c6050ef060877ebe77b41d959e9df13f8c9b5e"
PKG_FILENAME="SQLite-c7c6050e.tar.gz?uuid=c7c6050ef060877ebe77b41d959e9df13f8c9b5e"
PKG_DIR="SQLite-c7c6050e"

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

./configure --prefix=${TGT} \
  --with-pic --enable-shared --enable-static \
  --enable-threadsafe --disable-tcl \
  --disable-debug | tee ${PKG_LOG_PFX}-configure.log
make 2>&1 | tee ${PKG_LOG_PFX}-make.log
make install 2>&1 | tee ${PKG_LOG_PFX}-make-install.log

date "+%Y/%m/%d %H:%M:%S" > ${TOP_BUILD_DIR}/.built.${PKG}

cd ${TOP_BUILD_DIR}
echo "${PKG} built."
