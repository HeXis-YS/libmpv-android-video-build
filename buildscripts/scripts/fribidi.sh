#!/bin/bash -e
source ../../include/path.sh

build=_build$ndk_suffix

unset CC CXX # meson wants these unset

meson setup $build \
	--cross-file "$prefix_dir/crossfile.txt" \
	-Dtests=false \
	-Ddocs=false

ninja -v -C $build -j$cores
DESTDIR="$prefix_dir" ninja -v -C $build install
