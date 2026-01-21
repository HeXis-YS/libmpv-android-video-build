#!/bin/bash -e
unset CC CXX # meson wants these unset

$_MESON \
	-Ddeprecated=false \
	-Dtests=false \
	-Dbin=false \
	-Ddocs=false

$_NINJA
DESTDIR="$prefix_dir" $_NINJA install
