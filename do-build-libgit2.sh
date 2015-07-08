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

PKG="libgit2"
PKG_URL="https://github.com/libgit2/libgit2/archive/v0.22.1.tar.gz"
PKG_FILENAME="libgit2-0.22.1.tar.gz"
PKG_DIR="libgit2-0.22.1"

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

mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=${TGT} -DTHREADSAFE=ON -DBUILD_SHARED_LIBS=ON 2>&1 | tee ${PKG_LOG_PFX}-cmake.log
cmake --build . --target install 2>&1 | tee ${PKG_LOG_PFX}-cmake-build-install.log

date "+%Y/%m/%d %H:%M:%S" > ${TOP_BUILD_DIR}/.built.${PKG}

cd ${TOP_BUILD_DIR}
echo "${PKG} built."
