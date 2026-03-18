#!/usr/bin/env bash
# Dependency versions
v_mpv=0.41.0
v_ffmpeg=8.0.1
v_mbedtls=3.6.5
v_openssl=3.6.1
v_dav1d=1.5.3
v_libwebp=1.6.0
v_libass=0.17.4
v_freetype=2-14-2
v_fribidi=1.0.16
v_harfbuzz=13.1.1
v_libplacebo=7.360.1

tls_dependency="$(tls_backend)"

# Dependency tree (dep_<name> => direct dependencies)
dep_mpv=(ffmpeg libass libplacebo)
dep_ffmpeg=("$tls_dependency" libwebp)
dep_mbedtls=()
dep_openssl=()
dep_libass=(freetype fribidi harfbuzz)
dep_freetype=()
dep_fribidi=()
dep_harfbuzz=()
dep_libmediakitandroidhelper=()
dep_libmedia_kit_native_event_loop=(libmediakitandroidhelper mpv)
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
