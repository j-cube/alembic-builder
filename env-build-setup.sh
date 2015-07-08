#!/bin/bash

if [[ $_ = $0 ]] ; then
  echo "ERROR: this build environment script MUST be sourced!"
  exit 1
fi

# BEWARE: OSX sets LC_CTYPE to "UTF-8" which is not valid on linux!
# This causes the build to FAIL.
#
# To avoid the error below when configuring alembic / git-em:
#   what(): locale::facet::_S_create_c_locale name not valid
# LC_CTYPE and/or LC_ALL (and LANG?) must be set to a valid value.
#
# See https://svn.boost.org/trac/boost/ticket/5928
# (for LC_* and LANG meaning, see http://pubs.opengroup.org/onlinepubs/7908799/xbd/envvar.html)
export LANG=en_US.UTF8
export LC_CTYPE=en_US.UTF8
#export LC_ALL=en_US.UTF8
##export LC_ALL=C

# determine this script directory
# see:
#   http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
#   http://stackoverflow.com/a/246128/1363486
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

export OLD_DIR=`pwd`
export TOP_BUILD_DIR=$DIR

source ${TOP_BUILD_DIR}/env-build-config.sh

if [ -z "${TGT}" ]; then
  echo "TGT variable not defined"
  exit 1
fi

export CXXFLAGS="-fPIC"
export CFLAGS="-fPIC"
# export CFLAGS="-m64 -fPIC"
export LDFLAGS="-fPIC"

#export TGT=/opt/jcube
export LD_LIBRARY_PATH=${TGT}/lib:${TGT}/lib/db4.7:${TGT}/alembic-1.5.3/lib:$LD_LIBRARY_PATH
export PYTHONPATH=${PYTHONPATH}:${TGT}/alembic-1.5.3/lib
export PATH=${TGT}/bin:${TGT}/alembic-1.5.3/bin:$PATH

if [ "${TARGET_64}" = "yes" ]; then
  echo "Selected 64 bit target architecture."
  export PKG_CONFIG_PATH=${TGT}/lib/pkgconfig:$PKG_CONFIG_PATH:/usr/lib/x86_64-linux-gnu/pkgconfig:/usr/lib/pkgconfig:/usr/share/pkgconfig
else
  echo "Selected 32 bit target architecture."
  export PKG_CONFIG_PATH=${TGT}/lib/pkgconfig:$PKG_CONFIG_PATH:/usr/lib/pkgconfig:/usr/share/pkgconfig
fi

export BUILD_DATETAG=`date "+%Y%m%d_%H%M"`
export BUILD_ROOT_LOG_DIR=${TOP_BUILD_DIR}/logs
export BUILD_LOG_DIR=${BUILD_ROOT_LOG_DIR}/${BUILD_DATETAG}
mkdir -p ${BUILD_LOG_DIR}
export LOG_PREFIX="${BUILD_LOG_DIR}/"

export BUILD_SETUP_READY=yes

echo
echo "Base Build environment is set."
echo

cd ${TOP_BUILD_DIR}
