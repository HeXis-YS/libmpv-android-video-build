#!/bin/bash -e
source ../../include/path.sh

./autogen.sh

mkdir -p $build_dir
pushd $build_dir

../configure \
	--host=$ndk_triple \
	--with-pic \
	--disable-asm \
	--enable-static\
	--disable-shared \
	--disable-require-system-font-provider

make -j$cores V=1
DESTDIR="$prefix_dir" make install

popd
