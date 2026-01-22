#!/bin/bash -e
./autogen.sh

mkdir -p $build_dir
pushd $build_dir

../configure \
	--host=$ndk_triple \
	--with-pic \
	--disable-shared \
	--disable-require-system-font-provider

$_MAKE
DESTDIR="$prefix_dir" $_MAKE install

popd
