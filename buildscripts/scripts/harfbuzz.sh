#!/bin/bash -e
unset CC CXX # meson wants these unset
: "${TARGET_PREFIX_DIR:?TARGET_PREFIX_DIR is not set}"

$_MESON \
	-Dtests=disabled \
	-Ddocs=disabled \
	-Dutilities=disabled

NDK_WRAPPER_APPEND="$NDK_WRAPPER_APPEND -Oz" $_NINJA
DESTDIR="$TARGET_PREFIX_DIR" $_NINJA install
