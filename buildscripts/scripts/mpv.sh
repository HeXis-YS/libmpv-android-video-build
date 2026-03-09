#!/bin/bash -e
unset CC CXX # meson wants these unset

target_lib_dir="$BUILD_DIR/output/lib/$prefix_name"

VULKAN_CONFIG="-Dvulkan=disabled"
if [ -n "$ENABLE_VULKAN" ]; then
	VULKAN_CONFIG="-Dvulkan=enabled"
fi

$_MESON \
	--prefer-static \
	--default-library shared \
	-Dgpl=false \
	-Dcplayer=false \
	-Dbuild-date=false \
	-Diconv=disabled \
	-Dlua=disabled \
	-Dcplugins=disabled \
	-Dmanpage-build=disabled \
	$VULKAN_CONFIG

$_NINJA
DESTDIR="$prefix_dir" $_NINJA install

mkdir -p "$target_lib_dir"
ln -sf "$prefix_dir/lib/libmpv.so" "$target_lib_dir/libmpv.so"
