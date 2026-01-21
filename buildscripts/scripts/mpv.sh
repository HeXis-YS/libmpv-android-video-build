#!/bin/bash -e
# Android provides Vulkan, but no pkgconfig file
# you can double-check the version in vulkan_core.h (-> VK_HEADER_VERSION)
mkdir -p "$prefix_dir"/lib/pkgconfig
cat >"$prefix_dir"/lib/pkgconfig/vulkan.pc <<"END"
Name: Vulkan
Description:
Version: 1.3.275
Libs: -lvulkan
Cflags:
END

unset CC CXX # meson wants these unset

VULKAN_CONFIG="-Dvulkan=disabled"
if [ -n "$ENABLE_VULKAN" ]; then
	VULKAN_CONFIG="-Dvulkan=enabled"
fi

$_MESON \
	--prefer-static \
	--default-library shared \
	-Dgpl=false \
	-Dlibmpv=true \
	-Dbuild-date=false \
	-Dlua=disabled \
	-Dcplayer=false \
	-Diconv=disabled \
	-Dmanpage-build=disabled \
	-Dcplugins=disabled \
	$VULKAN_CONFIG

$_NINJA
DESTDIR="$prefix_dir" $_NINJA install

ln -sf "$prefix_dir/lib/libmpv.so" "$native_dir"
