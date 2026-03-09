#!/bin/bash -e
: "${TARGET_PREFIX_DIR:?TARGET_PREFIX_DIR is not set}"
./autogen.sh

mkdir -p $build_dir
pushd $build_dir

NDK_WRAPPER_DISABLED=1 ../configure \
	--host=$ndk_triple \
	--with-pic \
	--disable-shared \
	--disable-require-system-font-provider \
	--enable-asm

$_MAKE
DESTDIR="$TARGET_PREFIX_DIR" $_MAKE install

popd
