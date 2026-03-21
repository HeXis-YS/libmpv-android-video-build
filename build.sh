#!/usr/bin/env bash
set -euo pipefail

export GRADLE_OPTS="-Dorg.gradle.daemon=false"
export JAVA_HOME="${JAVA_HOME_17_X64:-${JAVA_HOME:-}}"
# Cortex-X3
export NDK_WRAPPER_APPEND="-march=armv9-a+crypto+nosve+bf16+fp16fml+i8mm+memtag+pmuv3+profile -mtune=cortex-a510"
export CUSTOM_FFMPEG_OPTIONS="--disable-runtime-cpudetect --disable-sve --disable-sve2"

export RUSTFLAGS=" \
    -C target-cpu=cortex-a510 -C target-feature=+crypto,-sve \
    -C opt-level=3 -C codegen-units=1 -C embed-bitcode=yes -C lto=fat \
    -C debuginfo=none -C force-frame-pointers=no -C force-unwind-tables=no -C panic=abort"

# export ENABLE_VULKAN=1
# export ENABLE_DAV1D=1
# export TLS_LIBRARY=mbedtls
# export TLS_LIBRARY=openssl

# export NDK_WRAPPER_DISABLED=1

buildscripts/build.sh
