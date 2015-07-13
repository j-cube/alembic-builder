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

export TGT=/opt/jcube
export PYTHON_VERSION=2.6

if [[ "$OSTYPE" == "linux-gnu" ]] ; then
  echo "linux detected"
  export TGT=/opt/jcube
elif [[ "$OSTYPE" == "darwin"* ]] ; then
  # Mac OSX
  echo "OS X detected"
  export TGT=${HOME}/jcube
elif [[ "$OSTYPE" == "cygwin" ]] ; then
  # POSIX compatibility layer and Linux environment emulation for Windows
  echo "Windows under CygWin detected"
  export TGT=/jcube
elif [[ "$OSTYPE" == "msys" ]] ; then
  # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
  echo "Windows under MinGW detected"
  export TGT=/jcube
elif [[ "$OSTYPE" == "win32" ]] ; then
  # I'm not sure this can happen.
  echo "Unknown Windows kind detected"
  export TGT=/jcube
elif [[ "$OSTYPE" == "freebsd"* ]] ; then
  echo "FreeBSD variant detected"
  export TGT=/opt/jcube
else
  # Unknown.
  echo "Unknown platform"
fi
echo "Set TGT to '${TGT}'"

# target system architecture addressing
# valid values: "yes" (64 bit), "no" (32 bit)
export TARGET_64=yes

# -- END OF USER-SETTABLE VARIABLES -----------------------------------

#export TARGET_PYTHON=${TGT}/bin/python${PYTHON_VERSION}
export TARGET_PYTHON=${TGT}/bin/python

export BUILD_CONFIG_READY=yes

echo "Build configuration setup."
