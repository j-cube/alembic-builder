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

PKG="gitem"
#PKG_URL="https://alembic.googlecode.com/files/Alembic_1.5.3_2013121700.tgz"
#PKG_FILENAME="Alembic_1.5.3_2013121700.tgz"
PKG_DIR="jcube-git-em"

cd ${TOP_BUILD_DIR}
#if [ -e ${TOP_BUILD_DIR}/.built.${PKG} ] ; then
#  echo "${PKG} already built"
#  exit 0
#fi

PKG_LOG_PFX="${LOG_PREFIX}${PKG}"

#if [ ! -e $PKG_FILENAME ] ; then
#  wget --content-disposition $PKG_URL
#fi

#if [ -e $PKG_DIR ] ; then
#  rm -rf $PKG_DIR
#fi
#tar xfz $PKG_FILENAME
#
## TODO: not sure this is needed now that we specify everything
#sudo updatedb

if [ ! -e $PKG_DIR ] ; then
  git clone git@github.com:j-cube/git-em.git $PKG_DIR
  cd $PKG_DIR
  git checkout 1.5.8/panta/dev
  cd ${TOP_BUILD_DIR}
fi

cd $PKG_DIR

ALEMBIC_BUILD_DIR=${TOP_BUILD_DIR}/gitem_build
if [ -e ${ALEMBIC_BUILD_DIR} ] ; then
  rm -rf ${ALEMBIC_BUILD_DIR}
fi
mkdir -p ${ALEMBIC_BUILD_DIR}

#cat ${TOP_BUILD_DIR}/Alembic_1.5.3_2013121700-jcube-v5.patch | patch -p1

export CMAKE_INSTALL_PREFIX=${TGT}
export ALEMBIC_INSTALL_PREFIX=${TGT}
#export PYILMBASE_ROOT=${TGT}/lib
export LIBPYTHON_VERSION=${PYTHON_VERSION}

# bootstrap
echo "Bootstrapping J-Cube git-em build..."
export CFLAGS="${CFLAGS} -Wno-deprecated-register -Wno-unused-function"
export CXXFLAGS="${CXXFLAGS} -Wno-deprecated-register -Wno-unused-function"
${TARGET_PYTHON} build/bootstrap/alembic_bootstrap.py \
  --dependency-install-root=${TGT} \
  --hdf5_include_dir=${TGT}/include \
  --hdf5_hdf5_library=${TGT}/lib/libhdf5.a \
  --ilmbase_include_dir=${TGT}/include/OpenEXR/ \
  --ilmbase_imath_library=${TGT}/lib/libImath.a \
  --boost_include_dir=${TGT}/include/boost-1_48 \
  --boost_thread_library=${TGT}/lib/libboost_thread-gcc46-mt-1_48.a \
  --boost_system_library=${TGT}/lib/libboost_system-gcc46-mt-1_48.a \
  --boost_filesystem_library=${TGT}/lib/libboost_filesystem-gcc46-mt-1_48.a \
  --boost_python_library=${TGT}/lib/libboost_python-gcc46-mt-1_48.a \
  --zlib_include_dir=${TGT}/include \
  --zlib_library=${TGT}/lib/libz.a \
  --profile \
  ${ALEMBIC_BUILD_DIR} 2>&1 | tee ${PKG_LOG_PFX}-bootstrap.log

# set install target directory
cmake -D CMAKE_INSTALL_PREFIX=${TGT} \
  -D Boost_LIBRARY_DIR:PATH="${TGT}/lib" \
  -D Boost_THREAD_LIBRARY_DEBUG:FILEPATH="${TGT}/lib/libboost_thread-gcc46-mt-1_48.a" \
  -D Boost_THREAD_LIBRARY_RELEASE:FILEPATH="${TGT}/lib/libboost_thread-gcc46-mt-1_48.a" \
  -D Boost_SYSTEM_LIBRARY_DEBUG:FILEPATH="${TGT}/lib/libboost_system-gcc46-mt-1_48.a" \
  -D Boost_SYSTEM_LIBRARY_RELEASE:FILEPATH="${TGT}/lib/libboost_system-gcc46-mt-1_48.a" \
  -D Boost_FILESYSTEM_LIBRARY_DEBUG:FILEPATH="${TGT}/lib/libboost_filesystem-gcc46-mt-1_48.a" \
  -D Boost_FILESYSTEM_LIBRARY_RELEASE:FILEPATH="${TGT}/lib/libboost_filesystem-gcc46-mt-1_48.a" \
  -D Boost_PROGRAM_OPTIONS_LIBRARY:FILEPATH="${TGT}/lib/libboost_program_options-gcc46-mt-1_48.a" \
  -D Boost_PROGRAM_OPTIONS_LIBRARY_DEBUG:FILEPATH="${TGT}/lib/libboost_program_options-gcc46-mt-1_48.a" \
  -D Boost_PROGRAM_OPTIONS_LIBRARY_RELEASE:FILEPATH="${TGT}/lib/libboost_program_options-gcc46-mt-1_48.a" \
  -D Boost_PYTHON_LIBRARY_DEBUG:FILEPATH="${TGT}/lib/libboost_python-gcc46-mt-1_48.a" \
  -D Boost_PYTHON_LIBRARY_RELEASE:FILEPATH="${TGT}/lib/libboost_python-gcc46-mt-1_48.a" \
  -D SQLITE3_INCLUDE_DIR:PATH="${TGT}/include" \
  -D SQLITE3_LIBRARY:FILEPATH="${TGT}/lib/libsqlite3.a" \
  ${ALEMBIC_BUILD_DIR}

echo "Compiling J-Cube git-em..."
cd ${ALEMBIC_BUILD_DIR}
make 2>&1 | tee ${PKG_LOG_PFX}-make.log
make install 2>&1 | tee ${PKG_LOG_PFX}-make-install.log
# cd python
# make 2>&1 | tee ${PKG_LOG_PFX}-python-make.log
# make install 2>&1 | tee ${PKG_LOG_PFX}-python-make-install.log

date "+%Y/%m/%d %H:%M:%S" > ${TOP_BUILD_DIR}/.built.${PKG}

cd ${TOP_BUILD_DIR}
echo "${PKG} built."
