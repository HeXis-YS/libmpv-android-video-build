#!/bin/bash -e

## Dependency versions

v_platform=android-36
v_sdk=13114758_latest
v_ndk=28.2.13676358
v_sdk_build_tools=36.0.0
v_cmake=4.1.1

v_libass=0.17.4
v_harfbuzz=11.5.0
v_fribidi=1.0.16
v_freetype=2-14-1
v_mbedtls=3.6.4
v_libplacebo=7.351.0
v_dav1d=1.5.1
v_libxml2=2.10.3
v_ffmpeg=8.0
v_mpv=0.40.0
v_libogg=1.3.5
v_libvorbis=1.3.7
v_libvpx=1.13
v_libwebp=1.6.0


## Dependency tree
# I would've used a dict but putting arrays in a dict is not a thing

dep_mbedtls=()
dep_dav1d=()
dep_libvorbis=(libogg)
if [ -n "$ENCODERS_GPL" ]; then
	dep_ffmpeg=(mbedtls dav1d libxml2 libvorbis libvpx libx264 libwebp)
else
	dep_ffmpeg=(mbedtls dav1d libxml2 libwebp)
fi
dep_freetype2=()
dep_fribidi=()
dep_harfbuzz=()
dep_libass=(freetype fribidi harfbuzz)
dep_lua=()
dep_shaderc=()
dep_libplacebo=()
if [ -n "$ENCODERS_GPL" ]; then
	dep_mpv=(ffmpeg libass libplacebo fftools_ffi)
else
	dep_mpv=(ffmpeg libass libplacebo)
fi
