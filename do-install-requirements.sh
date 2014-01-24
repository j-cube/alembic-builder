#!/bin/bash

set -e

if [ -z "${BUILD_SETUP_READY}" ] ; then
  . env-build-setup.sh
fi

if [ -z "${TGT}" ] ; then
  echo "ERROR: TGT variable not set."
  exit 1
fi

APT_GET="apt-get"
APT_OPTIONS="-q --assume-yes --no-install-recommends --no-upgrade"

sudo ${APT_GET} -q update
sudo ${APT_GET} -q clean
sudo ${APT_GET} ${APT_OPTIONS} install build-essential zlib1g-dev
sudo ${APT_GET} ${APT_OPTIONS} install manpages-dev autoconf2.13 automake libtool id-utils
sudo ${APT_GET} ${APT_OPTIONS} install gcc g++ make cmake
sudo ${APT_GET} ${APT_OPTIONS} install libjpeg-dev libtiff4-dev libpng12-dev
sudo ${APT_GET} ${APT_OPTIONS} install python2.7-dev python-setuptools ipython python-numpy python-sphinx
sudo ${APT_GET} ${APT_OPTIONS} install libreadline-dev sqlite3 libsqlite3-dev libpcre3-dev libncursesw5-dev libncurses5-dev libssl-dev libdb-dev libgdbm-dev libbz2-dev

sudo ${APT_GET} ${APT_OPTIONS} install gfortran
sudo ${APT_GET} ${APT_OPTIONS} install libgl1-mesa-dev libglew1.6-dev freeglut3 freeglut3-dev libxmu-dev libxi-dev
sudo ${APT_GET} ${APT_OPTIONS} install doxygen
sudo ${APT_GET} -q clean
