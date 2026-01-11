#!/bin/bash -e
source ../../include/path.sh

unset CC CXX # meson wants these unset

meson setup $build_dir \
	--cross-file "$prefix_dir/crossfile.txt" \
	-Ddefault_library=static \
	-Dcpu_features_path="$ANDROID_NDK_LATEST_HOME/sources/android/cpufeatures"

ninja -v -C $build_dir -j$cores
DESTDIR="$prefix_dir" ninja -v -C $build_dir install
