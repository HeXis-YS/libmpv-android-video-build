#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"

# This build system only supports Linux
if [[ "$OSTYPE" != linux* ]]; then
	echo "Error: This build system only supports Linux." >&2
	echo "OSTYPE detected: $OSTYPE" >&2
	exit 1
fi

[ -z "$cores" ] && cores=$(grep -c ^processor /proc/cpuinfo)
cores=${cores:-4}

# configure pkg-config paths if inside buildscripts
if [ -n "$ndk_triple" ]; then
	export PKG_CONFIG_SYSROOT_DIR="$prefix_dir"
	export PKG_CONFIG_LIBDIR="$PKG_CONFIG_SYSROOT_DIR/lib/pkgconfig"
	unset PKG_CONFIG_PATH
fi

toolchain=$(echo "$DIR/sdk/android-sdk-linux/ndk/$v_ndk/toolchains/llvm/prebuilt/"*)
export PATH="$toolchain/bin:$DIR/sdk/android-sdk-linux/ndk/$v_ndk:$DIR/sdk/bin:$PATH"
export ANDROID_HOME="$DIR/sdk/android-sdk-linux"
unset ANDROID_SDK_ROOT ANDROID_NDK_ROOT

# Common optimization flags for all builds
export OPT_FLAGS="-O3 -DNDEBUG -flto"
export OPT_CFLAGS="-O3 -fPIC -DNDEBUG -flto"
export OPT_CXXFLAGS="-O3 -fPIC -DNDEBUG -flto"
# Meson-compatible array format for crossfile
export OPT_MESON_ARGS="['-O3', '-fPIC', '-DNDEBUG', '-flto']"
