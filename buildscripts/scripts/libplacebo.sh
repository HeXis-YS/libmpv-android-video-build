#!/bin/bash -e
source ../../include/path.sh

unset CC CXX
meson setup $build_dir \
	--cross-file "$prefix_dir/crossfile.txt" \
	-Dvulkan=disabled \
	-Ddemos=false

ninja -v -C $build_dir -j$cores
DESTDIR="$prefix_dir" ninja -v -C $build_dir install

# add missing library for static linking
# this isn't "-lstdc++" due to a meson bug: https://github.com/mesonbuild/meson/issues/11300
${SED:-sed} '/^Libs:/ s|$| -lc++|' "$prefix_dir/lib/pkgconfig/libplacebo.pc" -i
