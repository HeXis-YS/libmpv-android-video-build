#!/bin/bash -e

. ./include/depinfo.sh

set -euo pipefail

GIT_CLONE="git clone --depth 1 --single-branch --no-tags"

# git config --global advice.detachedHead false

mkdir -p deps 
pushd deps

# mbedtls
[ ! -d mbedtls ] && $GIT_CLONE --branch v$v_mbedtls --recurse-submodules --shallow-submodules https://github.com/Mbed-TLS/mbedtls.git mbedtls

# dav1d
[ ! -d dav1d ] && $GIT_CLONE --branch $v_dav1d https://code.videolan.org/videolan/dav1d.git dav1d

# libvpx
[ ! -d libvpx ] && $GIT_CLONE --branch meson-$v_libvpx https://gitlab.freedesktop.org/gstreamer/meson-ports/libvpx.git libvpx

# libx264
[ ! -d libx264 ] && $GIT_CLONE --branch master https://code.videolan.org/videolan/x264.git libx264

# ffmpeg
[ ! -d ffmpeg ] && $GIT_CLONE --branch n$v_ffmpeg https://github.com/FFmpeg/FFmpeg.git ffmpeg

# freetype2
[ ! -d freetype ] && $GIT_CLONE --branch VER-$v_freetype https://gitlab.freedesktop.org/freetype/freetype.git freetype

# fribidi
[ ! -d fribidi ] && $GIT_CLONE --branch v$v_fribidi https://github.com/fribidi/fribidi.git fribidi

# harfbuzz
[ ! -d harfbuzz ] && $GIT_CLONE --branch $v_harfbuzz https://github.com/harfbuzz/harfbuzz.git harfbuzz

# libass
[ ! -d libass ] && $GIT_CLONE --branch $v_libass https://github.com/libass/libass.git libass

# libwebp
[ ! -d libwebp ] && $GIT_CLONE --branch v$v_libwebp https://github.com/webmproject/libwebp.git libwebp

# shaderc
mkdir -p shaderc
cat >shaderc/README <<'HEREDOC'
Shaderc sources are provided by the NDK.
see <ndk>/sources/third_party/shaderc
HEREDOC

# libplacebo
[ ! -d libplacebo ] && $GIT_CLONE --branch v$v_libplacebo --recurse-submodules --shallow-submodules https://code.videolan.org/videolan/libplacebo.git libplacebo

# mpv
[ ! -d mpv ]  && $GIT_CLONE --branch v$v_mpv https://github.com/mpv-player/mpv.git mpv

# fftools_ffi
[ ! -d fftools_ffi ] && $GIT_CLONE --branch main https://github.com/moffatman/fftools-ffi.git fftools_ffi

# media-kit-android-helper
[ ! -d media-kit-android-helper ] && $GIT_CLONE --branch main https://github.com/media-kit/media-kit-android-helper.git media-kit-android-helper

# media_kit
[ ! -d media_kit ] && $GIT_CLONE --single-branch --branch version_1.2.5 https://github.com/bggRGjQaUbCoE/media-kit.git media_kit

popd
