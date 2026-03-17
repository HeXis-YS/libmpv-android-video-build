#!/bin/bash -e
unset CC CXX # meson wants these unset
: "${TARGET_PREFIX_DIR:?TARGET_PREFIX_DIR is not set}"

$_MESON \
	-Dglib=disabled \
	-Dgobject=disabled \
	-Dcairo=disabled \
	-Dchafa=disabled \
	-Dpng=disabled \
	-Dzlib=disabled \
	-Dicu=disabled \
	-Dfreetype=disabled \
	-Draster=disabled \
	-Dvector=disabled \
	-Dsubset=disabled \
	-Dtests=disabled \
	-Dintrospection=disabled \
	-Ddocs=disabled \
	-Dutilities=disabled

$_NINJA
DESTDIR="$TARGET_PREFIX_DIR" $_NINJA install
