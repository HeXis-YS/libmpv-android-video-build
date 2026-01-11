#!/bin/bash -e
source ../../include/path.sh

unset CC CXX # meson wants these unset

meson setup $build_dir \
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

ninja -v -C $build_dir -j$cores
DESTDIR="$prefix_dir" ninja -v -C $build_dir install

ln -sf "$prefix_dir"/lib/libmpv.so "$native_dir"
