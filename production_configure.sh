#!/bin/sh

rm -rf build
mkdir build
cd build

cmake \
  -DCMAKE_INSTALL_PREFIX:PATH=/hao/acos/sw/pipeline/comp-pipeline \
  -DIDL_ROOT_DIR:PATH=/opt/share/idl8.6/idl86 \
  -DIDLdoc_DIR:PATH=~/projects/idldoc \
  -Dmgunit_DIR:PATH=~/projects/mgunit/src \
  ..
