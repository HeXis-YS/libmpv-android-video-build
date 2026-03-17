#!/bin/bash -e
unset CC CXX # meson wants these unset
: "${TARGET_PREFIX_DIR:?TARGET_PREFIX_DIR is not set}"

$_MESON \
	-Dtest=disabled \
	-Dcompare=disabled \
	-Dprofile=disabled \
	-Dfuzz=disabled \
	-Dcheckasm=disabled \
	-Dfontconfig=disabled \
	-Dasm=enabled \
	-Dlibunibreak=disabled \
	-Drequire-system-font-provider=false \
	-Dlarge-tiles=true

$_NINJA
DESTDIR="$TARGET_PREFIX_DIR" $_NINJA install
