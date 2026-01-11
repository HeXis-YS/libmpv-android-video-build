#!/bin/bash -e
source ../../include/path.sh

build=_build$ndk_suffix

unset CC CXX # meson wants these unset

meson setup $build \
	--cross-file "$prefix_dir/crossfile.txt" \
	--prefer-static \
	--default-library shared \
	-Dgpl=false \
	-Dlibmpv=true \
	-Dbuild-date=false \
 	-Dlua=disabled \
 	-Dcplayer=false \
	-Diconv=disabled \
	-Dvulkan=disabled \
 	-Dmanpage-build=disabled

ninja -v -C $build -j$cores
DESTDIR="$prefix_dir" ninja -v -C $build install

ln -sf "$prefix_dir"/lib/libmpv.so "$native_dir"
