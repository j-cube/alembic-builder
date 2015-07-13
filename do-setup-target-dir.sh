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
  sudo mkdir -p ${TGT}
  # sudo chgrp -R developers ${TGT}
  sudo chmod g+rwx ${TGT}
fi
