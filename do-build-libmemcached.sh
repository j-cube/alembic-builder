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

PKG="libmemcached"
PKG_URL="https://launchpad.net/libmemcached/1.0/0.53/+download/libmemcached-0.53.tar.gz"
PKG_FILENAME="libmemcached-0.53.tar.gz"
PKG_DIR="libmemcached-0.53"

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
  --disable-debug | tee ${PKG_LOG_PFX}-configure.log
make 2>&1 | tee ${PKG_LOG_PFX}-make.log
make install 2>&1 | tee ${PKG_LOG_PFX}-make-install.log

date "+%Y/%m/%d %H:%M:%S" > ${TOP_BUILD_DIR}/.built.${PKG}

cd ${TOP_BUILD_DIR}
echo "${PKG} built."
