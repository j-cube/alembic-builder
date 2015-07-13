#!/bin/bash

if [[ $_ = $0 ]] ; then
  echo "ERROR: the build config script MUST be sourced!"
  exit 1
fi

if [ -z "${TOP_BUILD_DIR}" ]; then
  echo "TOP_BUILD_DIR variable not defined"
  exit 1
fi

# -- Edit variables here ----------------------------------------------

#export TGT=/opt/jcube
export TGT=${HOME}/jcube
export PYTHON_VERSION=2.6

# target system architecture addressing
# valid values: "yes" (64 bit), "no" (32 bit)
export TARGET_64=yes

# -- END OF USER-SETTABLE VARIABLES -----------------------------------

#export TARGET_PYTHON=${TGT}/bin/python${PYTHON_VERSION}
export TARGET_PYTHON=${TGT}/bin/python

export BUILD_CONFIG_READY=yes

echo "Build configuration setup."
