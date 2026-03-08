#!/bin/bash -e
source $BUILDSCRIPTS_DIR/include/depinfo.sh

set -eo pipefail

# Dependencies
pip install meson

GIT_CLONE="git clone --depth 1 --single-branch --no-tags"

mkdir -p $DEPS_DIR
pushd $DEPS_DIR

# flutter
git clone --depth 1 --single-branch -b stable https://github.com/flutter/flutter &

# mpv
$GIT_CLONE -b release/$v_mpv https://github.com/HeXis-YS/mpv.git mpv &

# ffmpeg
$GIT_CLONE -b n$v_ffmpeg https://github.com/FFmpeg/FFmpeg.git ffmpeg &

if [ -n "$ENABLE_DAV1D" ]; then
	# dav1d
	$GIT_CLONE -b $v_dav1d https://code.videolan.org/videolan/dav1d.git dav1d &
fi

# mbedtls
$GIT_CLONE -b v$v_mbedtls --recurse-submodules --shallow-submodules https://github.com/Mbed-TLS/mbedtls.git mbedtls &

# libwebp
$GIT_CLONE -b v$v_libwebp https://github.com/webmproject/libwebp.git libwebp &

# libplacebo
$GIT_CLONE -b v$v_libplacebo --recurse-submodules --shallow-submodules https://code.videolan.org/videolan/libplacebo.git libplacebo &

if [ -n "$ENABLE_VULKAN" ]; then
	# shaderc
	mkdir -p shaderc
fi

# media-kit-android-helper
$GIT_CLONE -b main https://github.com/media-kit/media-kit-android-helper.git media-kit-android-helper &

# media_kit
$GIT_CLONE -b version_1.2.5 https://github.com/bggRGjQaUbCoE/media-kit.git media_kit &

wait

popd
