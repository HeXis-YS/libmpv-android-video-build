#!/bin/bash -e
## Dependency versions

v_mpv=0.41.0
v_ffmpeg=8.0.1
v_mbedtls=3.6.5
v_dav1d=1.5.3
v_libwebp=1.6.0
v_libplacebo=7.351.0


## Dependency tree
# I would've used a dict but putting arrays in a dict is not a thing

dep_mpv=(ffmpeg libplacebo)
if [ -n "$ENABLE_DAV1D" ]; then
	dep_ffmpeg=(dav1d mbedtls libwebp)
		dep_dav1d=()
else
	dep_ffmpeg=(mbedtls libwebp)
fi
		dep_mbedtls=()
		dep_libwebp=()
if [ -n "$ENABLE_VULKAN" ]; then
	dep_libplacebo=(shaderc)
		dep_shaderc=()
else
	dep_libplacebo=()
fi
