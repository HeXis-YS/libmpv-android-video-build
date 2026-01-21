#!/bin/bash -e
unset CC CXX # meson wants these unset

$_MESON \
	-Dtests=disabled \
	-Ddocs=disabled \
	-Dutilities=disabled

$_NINJA
DESTDIR="$prefix_dir" $_NINJA install
