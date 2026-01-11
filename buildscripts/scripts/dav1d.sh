#!/bin/bash -e
source ../../include/path.sh

unset CC CXX # meson wants these unset

$MESON_SETUP \
	-Denable_tests=false \
	-Dstack_alignment=16

$NINJA
DESTDIR="$prefix_dir" $NINJA install
