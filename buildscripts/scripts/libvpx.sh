#!/bin/bash -e
source ../../include/path.sh

unset CC CXX # meson wants these unset

$MESON_SETUP \
	-Ddefault_library=static \
	-Dcpu_features_path="$ANDROID_NDK_LATEST_HOME/sources/android/cpufeatures"

$NINJA
DESTDIR="$prefix_dir" $NINJA install
