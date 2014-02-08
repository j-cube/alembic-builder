#!/bin/bash

if [[ $_ != $0 ]] ; then
  echo "Setup script sourced, ok"
else
  echo "ERROR: this script MUST be sourced!"
  exit 1
fi

# export CXXFLAGS="-fPIC"
# export CFLAGS="-fPIC"
# export CFLAGS="-m64 -fPIC"
# export LDFLAGS="-fPIC"

export TGT=/opt/jcube
export LD_LIBRARY_PATH=/opt/jcube/lib:/opt/jcube/lib/db4.7:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=/opt/jcube/lib/pkgconfig:$PKG_CONFIG_PATH:/usr/lib/pkgconfig
export PATH=/opt/jcube/bin:$PATH

export CPPFLAGS="-I/opt/jcube/lib/python2.6/site-packages/numpy/core/include/"

echo
echo "pyilmbase Build environment setup."
echo
