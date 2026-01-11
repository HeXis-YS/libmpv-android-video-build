#!/bin/bash -e
source ../../include/path.sh

build=_build$ndk_suffix

unset CC CXX
meson setup $build \
	--cross-file "$prefix_dir/crossfile.txt" \
	-Dvulkan=disabled \
	-Ddemos=false

ninja -v -C $build -j$cores
DESTDIR="$prefix_dir" ninja -v -C $build install

# add missing library for static linking
# this isn't "-lstdc++" due to a meson bug: https://github.com/mesonbuild/meson/issues/11300
${SED:-sed} '/^Libs:/ s|$| -lc++|' "$prefix_dir/lib/pkgconfig/libplacebo.pc" -i
