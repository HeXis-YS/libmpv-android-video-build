#!/bin/bash -e
source ../../include/path.sh

unset CC CXX # meson wants these unset

$MESON_SETUP \
	-Dtests=false \
	-Ddocs=false

$NINJA
DESTDIR="$prefix_dir" $NINJA install
