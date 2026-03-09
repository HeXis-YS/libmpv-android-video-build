#!/usr/bin/env bash
set -euo pipefail

unset CC CXX # meson wants these unset

: "${BUILD_DIR:?BUILD_DIR is not set}"
: "${TARGET_ABI:?TARGET_ABI is not set}"
: "${prefix_dir:?prefix_dir is not set}"

target_lib_dir="${TARGET_LIB_DIR:-$BUILD_DIR/output/lib/$TARGET_ABI}"

VULKAN_CONFIG="-Dvulkan=disabled"
if [[ -n "${ENABLE_VULKAN:-}" ]]; then
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
