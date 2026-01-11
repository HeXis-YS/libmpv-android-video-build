#!/bin/bash -e
source ../../include/path.sh

build=_build$ndk_suffix

mkdir -p $build
cd $build

cmake .. \
	-DENABLE_TESTING=OFF \
	-DUSE_SHARED_MBEDTLS_LIBRARY=ON \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_PREFIX_PATH="$prefix_dir" \
	-DCMAKE_PLATFORM_NO_VERSIONED_SONAME=ON \
	-DCMAKE_VERBOSE_MAKEFILE=ON

make -j$cores VERBOSE=1
DESTDIR="$prefix_dir" make install
