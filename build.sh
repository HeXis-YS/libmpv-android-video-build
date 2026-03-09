#!/usr/bin/env bash
set -euo pipefail

export GRADLE_OPTS="-Dorg.gradle.daemon=false"
export JAVA_HOME="${JAVA_HOME_17_X64:-${JAVA_HOME:-}}"
export NDK_WRAPPER_APPEND="-mcpu=cortex-x3+crypto+sha3+nosve -mtune=cortex-a510"
export CUSTOM_FFMPEG_OPTIONS="--disable-runtime-cpudetect --disable-sve --disable-sve2"

# export ENABLE_VULKAN=1
# export ENABLE_DAV1D=1

buildscripts/build.sh
