#!/usr/bin/env bash
# Dependency versions
v_mpv=0.41.0
v_ffmpeg=8.0.1
v_mbedtls=3.6.5
v_dav1d=1.5.3
v_libwebp=1.6.0
v_libplacebo=7.351.0

# Dependency tree (dep_<name> => direct dependencies)
dep_mpv=(ffmpeg libplacebo)
dep_ffmpeg=(mbedtls libwebp)
dep_mbedtls=()
dep_libwebp=()
dep_libplacebo=()

if [[ -n "${ENABLE_DAV1D:-}" ]]; then
	dep_ffmpeg=(dav1d "${dep_ffmpeg[@]}")
	dep_dav1d=()
fi

if [[ -n "${ENABLE_VULKAN:-}" ]]; then
	dep_libplacebo=(shaderc)
	dep_shaderc=()
fi
