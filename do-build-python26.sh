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

PKG="python26"
PKG_URL="http://www.python.org/ftp/python/2.6.8/Python-2.6.8.tgz"
PKG_FILENAME="Python-2.6.8.tgz"
PKG_DIR="Python-2.6.8"

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

if [ "${TARGET_64}" = "yes" ] ; then
  # apply the patch for x86_64 lib finding
  cat ${TOP_BUILD_DIR}/python-2.6.8-x86_64.patch | patch -p1
fi

# apply the patch for finding our Berkeley DB from /opt/jcube
cat ${TOP_BUILD_DIR}/python-2.6.8-jcube-bdb.patch | patch -p1

# apply the patch for ssl
cat ${TOP_BUILD_DIR}/python-2.6.8-ssl.patch | patch -p1

if [ "${TARGET_64}" = "yes" ] ; then
  CPPFLAGS="-I/usr/lib/x86_64-linux-gnu" LDFLAGS="-L/usr/include/x86_64-linux-gnu" ./configure --prefix=${TGT} \
    --enable-shared --with-ssl 2>&1 | tee ${PKG_LOG_PFX}-configure.log
else
  ./configure --prefix=${TGT} --enable-shared --with-ssl 2>&1 | tee ${PKG_LOG_PFX}-configure.log
fi

make 2>&1 | tee ${PKG_LOG_PFX}-make.log
#make test 2>&1 | tee ${PKG_LOG_PFX}-make-test.log
make install 2>&1 | tee ${PKG_LOG_PFX}-make-install.log

# install setuptools/easy_install and pip
wget https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py -O - | ${TARGET_PYTHON}
wget https://raw.github.com/pypa/pip/master/contrib/get-pip.py -O - | ${TARGET_PYTHON}

date "+%Y/%m/%d %H:%M:%S" > ${TOP_BUILD_DIR}/.built.${PKG}

cd ${TOP_BUILD_DIR}
echo "${PKG} built."
