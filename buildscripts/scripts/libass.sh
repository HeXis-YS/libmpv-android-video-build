#!/bin/bash -e
unset CC CXX # meson wants these unset
: "${TARGET_PREFIX_DIR:?TARGET_PREFIX_DIR is not set}"

$_MESON \
	-Dauto_features=disabled \
	-Dasm=enabled \
	-Drequire-system-font-provider=false \
	-Dlarge-tiles=true

$_NINJA
DESTDIR="$TARGET_PREFIX_DIR" $_NINJA install
