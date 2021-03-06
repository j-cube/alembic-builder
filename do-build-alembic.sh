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

PKG="alembic"
PKG_URL="https://alembic.googlecode.com/files/Alembic_1.5.3_2013121700.tgz"
PKG_FILENAME="Alembic_1.5.3_2013121700.tgz"
PKG_DIR="Alembic_1.5.3_2013121700"

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

# TODO: not sure this is needed now that we specify everything
sudo updatedb

cd $PKG_DIR

ALEMBIC_BUILD_DIR=${TOP_BUILD_DIR}/alembic_build
if [ -e ${ALEMBIC_BUILD_DIR} ] ; then
  rm -rf ${ALEMBIC_BUILD_DIR}
fi
mkdir -p ${ALEMBIC_BUILD_DIR}

cat ${TOP_BUILD_DIR}/Alembic_1.5.3_2013121700-jcube-v5.patch | patch -p1

export CMAKE_INSTALL_PREFIX=${TGT}
export ALEMBIC_INSTALL_PREFIX=${TGT}
export PYILMBASE_ROOT=${TGT}/lib
export LIBPYTHON_VERSION=${PYTHON_VERSION}

# bootstrap
echo "Bootstrapping Alembic build..."
${TARGET_PYTHON} build/bootstrap/alembic_bootstrap.py \
  --dependency-install-root=${TGT} \
  --hdf5_include_dir=${TGT}/include \
  --hdf5_hdf5_library=${TGT}/lib/libhdf5.a \
  --ilmbase_include_dir=${TGT}/include/OpenEXR/ \
  --ilmbase_imath_library=${TGT}/lib/libImath.a \
  --pyilmbase_include_dir=${TGT}/include/OpenEXR/ \
  --pyilmbase_pyimath_library=${TGT}/lib/libPyImath.so \
  --pyilmbase_pyimath_module=${TGT}/lib/python${PYTHON_VERSION}/site-packages/imathmodule.so \
  --boost_include_dir=${TGT}/include/boost-1_48 \
  --boost_thread_library=${TGT}/lib/libboost_thread-gcc46-mt-1_48.a \
  --boost_python_library=${TGT}/lib/libboost_python-gcc46-mt-1_48.a \
  --zlib_include_dir=${TGT}/include \
  --zlib_library=${TGT}/lib/libz.a \
  --enable-pyalembic \
  ${ALEMBIC_BUILD_DIR} 2>&1 | tee ${PKG_LOG_PFX}-bootstrap.log

# set install target directory
cmake -D CMAKE_INSTALL_PREFIX=${TGT} ${ALEMBIC_BUILD_DIR}

echo "Compiling Alembic..."
cd ${ALEMBIC_BUILD_DIR}
make 2>&1 | tee ${PKG_LOG_PFX}-make.log
make install 2>&1 | tee ${PKG_LOG_PFX}-make-install.log
cd python
make 2>&1 | tee ${PKG_LOG_PFX}-python-make.log
make install 2>&1 | tee ${PKG_LOG_PFX}-python-make-install.log

date "+%Y/%m/%d %H:%M:%S" > ${TOP_BUILD_DIR}/.built.${PKG}

cd ${TOP_BUILD_DIR}
echo "${PKG} built."
