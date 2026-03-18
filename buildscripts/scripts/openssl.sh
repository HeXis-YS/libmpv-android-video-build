#!/usr/bin/env bash
set -euo pipefail

: "${ANDROID_NDK_LATEST_HOME:?ANDROID_NDK_LATEST_HOME is not set}"
: "${BUILDSCRIPTS_DIR:?BUILDSCRIPTS_DIR is not set}"
: "${TARGET_PREFIX_DIR:?TARGET_PREFIX_DIR is not set}"

source "$BUILDSCRIPTS_DIR/include/common.sh"

android_api_level="${ANDROID_API_LEVEL:-24}"
openssl_target="android-arm64"

case "${TARGET_ABI:-arm64-v8a}" in
arm64-v8a)
	openssl_target="android-arm64"
	;;
armeabi-v7a)
	openssl_target="android-arm"
	;;
x86)
	openssl_target="android-x86"
	;;
x86_64)
	openssl_target="android-x86_64"
	;;
*)
	die "Unsupported OpenSSL TARGET_ABI: ${TARGET_ABI:-<unset>}"
	;;
esac

export ANDROID_NDK_ROOT="$ANDROID_NDK_LATEST_HOME"

NDK_WRAPPER_DISABLED=1 ./Configure \
	"$openssl_target" \
	"-D__ANDROID_API__=$android_api_level" \
	-fPIC \
	no-apps \
	no-docs \
	no-tests \
	no-shared \
	no-pinshared \
	--prefix=$TARGET_PREFIX_DIR

NDK_WRAPPER_APPEND="$NDK_WRAPPER_APPEND -Wno-macro-redefined" $_MAKE
$_MAKE install_sw
