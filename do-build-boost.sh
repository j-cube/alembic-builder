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

PKG="boost"
PKG_URL="http://sourceforge.net/projects/boost/files/boost/1.48.0/boost_1_48_0.tar.bz2/download"
PKG_FILENAME="boost_1_48_0.tar.bz2"
PKG_DIR="boost_1_48_0"

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
# read ${TOP_BUILD_DIR}/Alembic/doc/Boost-howtobuild.txt

export CXXFLAGS="-fPIC"
export CFLAGS="-fPIC"
export LDFLAGS="-fPIC"
umask 022

# apply fix for https://svn.boost.org/trac/boost/ticket/6165
wget -q --content-disposition -O - https://svn.boost.org/trac/boost/raw-attachment/ticket/6165/libstdcpp3.hpp.patch | patch -p 0

# fix https://svn.boost.org/trac/boost/ticket/6940
#sed -i 's/TIME_UTC/TIME_UTC_/g' boost/thread/xtime.hpp
find . -type f -exec perl -p -i -e 's/TIME_UTC/TIME_UTC_/g' \{\} \;

# TODO: should we pass ${TARGET_PYTHON} to --with-python ?
./bootstrap.sh --prefix=${TGT} \
  --with-libraries=program_options,thread,python \
  --with-python=python \
  --with-python-version=${PYTHON_VERSION} 2>&1 | tee ${PKG_LOG_PFX}-bootstrap.log
./bjam install --layout=versioned link=static threading=multi cxxflags=-fPIC  2>&1 | tee ${PKG_LOG_PFX}-bjam-install.log

date "+%Y/%m/%d %H:%M:%S" > ${TOP_BUILD_DIR}/.built.${PKG}

cd ${TOP_BUILD_DIR}
echo "${PKG} built."
