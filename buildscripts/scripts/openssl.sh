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
	no-autoalginit no-autoerrinit no-atexit no-pinshared no-autoload-config no-makedepend no-deprecated --api=1.0.2 \
	no-stdio no-ui-console no-docs no-dso no-err no-filenames no-posix-io no-secure-memory no-engine \
	no-legacy no-integrity-only-ciphers no-tls-deprecated-ec \
	no-cmp no-cms no-comp no-ct no-ts no-psk no-slh-dsa no-rfc3779 no-nextprotoneg \
	no-sock no-ssl-trace no-srp no-http \
	no-tls1-method no-tls1_1-method no-tls1_2-method no-ssl-trace no-multiblock \
	no-dtls1-method no-dtls1_2-method \
	no-ec2m no-ecdsa no-ecdh no-gost \
	no-ml-dsa no-ml-kem \
	no-chacha no-poly1305 \
	no-aria no-bf no-blake2 no-camellia no-cast no-cmac no-des no-dh no-dsa no-idea no-md4 no-ocb no-rc2 no-rc4 no-rmd160 no-scrypt no-seed no-siphash no-sm2-precomp no-sm3 no-sm4 no-whirlpool \
	no-sse2 no-rdrand \
	--prefix=$TARGET_PREFIX_DIR

NDK_WRAPPER_APPEND="$NDK_WRAPPER_APPEND -Wno-macro-redefined" $_MAKE
$_MAKE install_sw
