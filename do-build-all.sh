#!/bin/bash

set -e

olddir=`pwd`

. env-build-setup.sh

if [ -z "${TGT}" ] ; then
  echo "ERROR: TGT variable not set."
  exit 1
fi

./do-setup-target-dir.sh

if [ ! -e ${TGT} ] ; then
  echo "ERROR: target directory ${TGT} doesn't exist."
  exit 1
fi

#./do-install-requirements.sh
./do-build-zlib.sh
./do-build-bzip2.sh
./do-build-db.sh
if [ "${PYTHON_VERSION}" = "2.6" ] ; then
  ./do-build-python26.sh
elif [ "${PYTHON_VERSION}" = "2.7" ] ; then
  ./do-build-python27.sh
fi
./do-build-boost-extended.sh
./do-build-ilmbase.sh
./do-build-numpy.sh
./do-build-pyilmbase.sh
./do-build-openexr.sh
./do-build-HDF5.sh
./do-build-msgpack.sh
./do-build-libgit2.sh
./do-build-sqlite.sh
./do-build-libmemcached.sh
#./do-build-alembic.sh
./do-build-gitem-debug.sh

cd ${OLD_DIR}
echo "Built everything."
