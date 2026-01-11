#!/bin/bash

DIR="$(dirname $(realpath $0))"

# This build system only supports Linux
if [[ "$OSTYPE" != linux* ]]; then
	echo "Error: This build system only supports Linux." >&2
	echo "OSTYPE detected: $OSTYPE" >&2
	exit 1
fi

cores=$(nproc)

# configure pkg-config paths if inside buildscripts
if [ -n "$ndk_triple" ]; then
	export PKG_CONFIG_SYSROOT_DIR="$prefix_dir"
	export PKG_CONFIG_LIBDIR="$PKG_CONFIG_SYSROOT_DIR/lib/pkgconfig"
	unset PKG_CONFIG_PATH
fi

export PATH="$ANDROID_NDK_LATEST_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH"
unset ANDROID_SDK_ROOT ANDROID_NDK_ROOT

# Common optimization flags for all builds
export OPT_FLAGS="-O3 -DNDEBUG -flto"
export OPT_CFLAGS="-O3 -fPIC -DNDEBUG -flto"
export OPT_CXXFLAGS="-O3 -fPIC -DNDEBUG -flto"
# Meson-compatible array format for crossfile
export OPT_MESON_ARGS="['-O3', '-fPIC', '-DNDEBUG', '-flto']"
