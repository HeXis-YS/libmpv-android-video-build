#!/bin/bash -e
source ../../include/path.sh

unset CC CXX # meson wants these unset

meson setup $build_dir \
	--cross-file "$prefix_dir/crossfile.txt" \
	-Dtests=disabled \
	-Ddocs=disabled

ninja -v -C $build_dir -j$cores
DESTDIR="$prefix_dir" ninja -v -C $build_dir install
