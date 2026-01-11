#!/bin/bash -e
source ../../include/path.sh

unset CC CXX # meson wants these unset

$MESON_SETUP \
	--prefer-static \
	--default-library shared \
	-Dgpl=false \
	-Dlibmpv=true \
	-Dbuild-date=false \
 	-Dlua=disabled \
 	-Dcplayer=false \
	-Diconv=disabled \
	-Dvulkan=disabled \
 	-Dmanpage-build=disabled

$NINJA
DESTDIR="$prefix_dir" $NINJA install

ln -sf "$prefix_dir"/lib/libmpv.so "$native_dir"
