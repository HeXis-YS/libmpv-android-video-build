#!/bin/bash -e

$_CMAKE \
	-DENABLE_PROGRAMS=OFF \
	-DENABLE_TESTING=OFF

$_NINJA
DESTDIR="$prefix_dir" $_NINJA install
