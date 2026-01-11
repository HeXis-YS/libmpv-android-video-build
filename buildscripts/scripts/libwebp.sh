#!/bin/bash -e
source ../../include/path.sh

mkdir -p $build_dir
pushd $build_dir

cmake .. \
	-DENABLE_SHARED=ON \
	-DENABLE_STATIC=OFF \
	-DENABLE_ENCRYPTION=ON \
	-DCMAKE_PREFIX_PATH="$prefix_dir" \
	-DUSE_ENCLIB=mbedtls \
	-DCMAKE_PLATFORM_NO_VERSIONED_SONAME=ON \
	-DCMAKE_VERBOSE_MAKEFILE=ON

$MAKE
DESTDIR="$prefix_dir" $MAKE install

popd
