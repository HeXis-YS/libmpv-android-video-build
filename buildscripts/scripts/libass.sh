#!/bin/bash -e
unset CC CXX # meson wants these unset

$_MESON \
	-Drequire-system-font-provider=false

$_NINJA
DESTDIR="$prefix_dir" $_NINJA install
