#!/bin/bash

#set -e

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

PKG="multiverse"
PKG_DIR="multiverse"

cd ${TOP_BUILD_DIR}
#if [ -e ${TOP_BUILD_DIR}/.built.${PKG} ] ; then
#  echo "${PKG} already built"
#  exit 0
#fi

PKG_LOG_PFX="${LOG_PREFIX}${PKG}"

#if [ -e $PKG_DIR ] ; then
#  rm -rf $PKG_DIR
#fi

## TODO: not sure this is needed now that we specify everything
#sudo updatedb

if [ ! -e $PKG_DIR ] ; then
  git clone https://github.com/j-cube/multiverse $PKG_DIR
  cd $PKG_DIR
  git checkout 1.5.8/multiverse
  cd ${TOP_BUILD_DIR}
fi

cd $PKG_DIR

perl -pi -e 's/ALEMBIC_NO_TESTS FALSE/ALEMBIC_NO_TESTS TRUE/' CMakeLists.txt

ALEMBIC_BUILD_DIR=${TOP_BUILD_DIR}/multiverse_build
if [ -e ${ALEMBIC_BUILD_DIR} ] ; then
  rm -rf ${ALEMBIC_BUILD_DIR}
fi
mkdir -p ${ALEMBIC_BUILD_DIR}

#cat ${TOP_BUILD_DIR}/Alembic_1.5.3_2013121700-jcube-v5.patch | patch -p1

export CMAKE_INSTALL_PREFIX=${TGT}
export ALEMBIC_INSTALL_PREFIX=${TGT}
#export PYILMBASE_ROOT=${TGT}/lib
export LIBPYTHON_VERSION=${PYTHON_VERSION}

# our BOOST_ROOT doesn't contain lib (it should contain {boost,lib,stage/lib})
#export BOOST_ROOT=${TGT}
#export BOOST_ROOT=${TGT}/lib
export BOOST_LIBRARYDIR=${TGT}/lib
export BOOST_INCLUDEDIR=${TGT}/include/boost-1_48

# Compiler tag and flags

if [[ "$OSTYPE" == "linux-gnu" ]] ; then
  # linux
  #GCC_TAG=gcc46
  GCC_TAG=gcc48
  # export CFLAGS="${CFLAGS} -Wno-unused-function"
  # export CXXFLAGS="${CXXFLAGS} -Wno-unused-function"
  export CFLAGS="${CFLAGS} -Wno-unused-function -Wno-unused-local-typedefs"
  export CXXFLAGS="${CXXFLAGS} -Wno-unused-function -Wno-unused-local-typedefs"
elif [[ "$OSTYPE" == "darwin"* ]] ; then
  # osx
  GCC_TAG=xgcc42
  export CFLAGS="${CFLAGS} -Wno-deprecated-register -Wno-unused-function"
  export CXXFLAGS="${CXXFLAGS} -Wno-deprecated-register -Wno-unused-function"
else
  # fallback
  GCC_TAG=gcc48
fi

# bootstrap
echo "Bootstrapping J-Cube multiverse build..."
${TARGET_PYTHON} build/bootstrap/alembic_bootstrap.py \
  --dependency-install-root=${TGT} \
  --hdf5_include_dir=${TGT}/include \
  --hdf5_hdf5_library=${TGT}/lib/libhdf5.a \
  --ilmbase_include_dir=${TGT}/include/OpenEXR/ \
  --ilmbase_imath_library=${TGT}/lib/libImath.a \
  --boost_include_dir=${TGT}/include/boost-1_48 \
  --boost_thread_library=${TGT}/lib/libboost_thread-${GCC_TAG}-mt-1_48.a \
  --boost_system_library=${TGT}/lib/libboost_system-${GCC_TAG}-mt-1_48.a \
  --boost_filesystem_library=${TGT}/lib/libboost_filesystem-${GCC_TAG}-mt-1_48.a \
  --boost_python_library=${TGT}/lib/libboost_python-${GCC_TAG}-mt-1_48.a \
  --zlib_include_dir=${TGT}/include \
  --zlib_library=${TGT}/lib/libz.a \
  --debug \
  ${ALEMBIC_BUILD_DIR} 2>&1 | tee ${PKG_LOG_PFX}-bootstrap.log

# set install target directory
# -D ALEMBIC_PYTHON_EXECUTABLE:FILEPATH="${TARGET_PYTHON}"
cmake -D CMAKE_INSTALL_PREFIX=${TGT} \
  -D Boost_LIBRARY_DIR:PATH="${TGT}/lib" \
  -D Boost_THREAD_LIBRARY_DEBUG:FILEPATH="${TGT}/lib/libboost_thread-${GCC_TAG}-mt-1_48.a" \
  -D Boost_THREAD_LIBRARY_RELEASE:FILEPATH="${TGT}/lib/libboost_thread-${GCC_TAG}-mt-1_48.a" \
  -D Boost_SYSTEM_LIBRARY_DEBUG:FILEPATH="${TGT}/lib/libboost_system-${GCC_TAG}-mt-1_48.a" \
  -D Boost_SYSTEM_LIBRARY_RELEASE:FILEPATH="${TGT}/lib/libboost_system-${GCC_TAG}-mt-1_48.a" \
  -D Boost_FILESYSTEM_LIBRARY_DEBUG:FILEPATH="${TGT}/lib/libboost_filesystem-${GCC_TAG}-mt-1_48.a" \
  -D Boost_FILESYSTEM_LIBRARY_RELEASE:FILEPATH="${TGT}/lib/libboost_filesystem-${GCC_TAG}-mt-1_48.a" \
  -D Boost_PROGRAM_OPTIONS_LIBRARY:FILEPATH="${TGT}/lib/libboost_program_options-${GCC_TAG}-mt-1_48.a" \
  -D Boost_PROGRAM_OPTIONS_LIBRARY_DEBUG:FILEPATH="${TGT}/lib/libboost_program_options-${GCC_TAG}-mt-1_48.a" \
  -D Boost_PROGRAM_OPTIONS_LIBRARY_RELEASE:FILEPATH="${TGT}/lib/libboost_program_options-${GCC_TAG}-mt-1_48.a" \
  -D Boost_PYTHON_LIBRARY_DEBUG:FILEPATH="${TGT}/lib/libboost_python-${GCC_TAG}-mt-1_48.a" \
  -D Boost_PYTHON_LIBRARY_RELEASE:FILEPATH="${TGT}/lib/libboost_python-${GCC_TAG}-mt-1_48.a" \
  -D SQLITE3_INCLUDE_DIR:PATH="${TGT}/include" \
  -D SQLITE3_LIBRARY:FILEPATH="${TGT}/lib/libsqlite3.a" \
  ${ALEMBIC_BUILD_DIR}

echo "Compiling J-Cube multiverse..."
cd ${ALEMBIC_BUILD_DIR}
make 2>&1 | tee ${PKG_LOG_PFX}-make.log
#make install 2>&1 | tee ${PKG_LOG_PFX}-make-install.log
# cd python
# make 2>&1 | tee ${PKG_LOG_PFX}-python-make.log
# make install 2>&1 | tee ${PKG_LOG_PFX}-python-make-install.log
cd ${ALEMBIC_BUILD_DIR}/examples
make
for p in AbcConvert AbcEcho AbcHistory AbcLs AbcTree ; do
  cd ${ALEMBIC_BUILD_DIR}/examples/bin/${p}
  make
  make install
done
cd ${ALEMBIC_BUILD_DIR}
make install 2>&1 | tee ${PKG_LOG_PFX}-make-install.log

date "+%Y/%m/%d %H:%M:%S" > ${TOP_BUILD_DIR}/.built.${PKG}

cd ${TOP_BUILD_DIR}
echo "${PKG} built."
