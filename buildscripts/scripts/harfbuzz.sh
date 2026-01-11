#!/bin/bash -e
source ../../include/path.sh

unset CC CXX # meson wants these unset

$MESON_SETUP \
	-Dtests=disabled \
	-Ddocs=disabled

$NINJA
DESTDIR="$prefix_dir" $NINJA install
