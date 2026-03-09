#!/bin/bash -e
unset CC CXX # meson wants these unset
: "${TARGET_PREFIX_DIR:?TARGET_PREFIX_DIR is not set}"

$_MESON \
	-Ddeprecated=false \
	-Dtests=false \
	-Dbin=false \
	-Ddocs=false

$_NINJA
DESTDIR="$TARGET_PREFIX_DIR" $_NINJA install
