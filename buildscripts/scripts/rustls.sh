#!/usr/bin/env bash
set -euo pipefail

: "${ANDROID_NDK_LATEST_HOME:?ANDROID_NDK_LATEST_HOME is not set}"
: "${BUILDSCRIPTS_DIR:?BUILDSCRIPTS_DIR is not set}"
: "${DEPS_DIR:?DEPS_DIR is not set}"
: "${TARGET_PREFIX_DIR:?TARGET_PREFIX_DIR is not set}"
: "${TARGET_ABI:?TARGET_ABI is not set}"

source "$BUILDSCRIPTS_DIR/include/common.sh"

command -v cargo >/dev/null 2>&1 || die "cargo not found in PATH"
command -v rustup >/dev/null 2>&1 || die "rustup not found in PATH"
cargo ndk --version >/dev/null 2>&1 || die "cargo-ndk not found; install it with: cargo install cargo-ndk"
require_file "$TARGET_PREFIX_DIR/lib/libcrypto.a" "$TARGET_PREFIX_DIR/include/openssl/ssl.h"

cargo_ndk_target="arm64-v8a"
cargo_target="aarch64-linux-android"
android_api_level="${ANDROID_API_LEVEL:-24}"
case "$TARGET_ABI" in
arm64-v8a)
	cargo_target="aarch64-linux-android"
	;;
armeabi-v7a)
	cargo_target="armv7-linux-androideabi"
	;;
x86)
	cargo_target="i686-linux-android"
	;;
x86_64)
	cargo_target="x86_64-linux-android"
	;;
*)
	die "Unsupported rustls TARGET_ABI: $TARGET_ABI"
	;;
esac
cargo_ndk_target="$TARGET_ABI"

ensure_dir "$TARGET_PREFIX_DIR/lib/pkgconfig"

if ! rustup target list --installed | grep -qx "$cargo_target"; then
	log_info "Installing Rust target: $cargo_target"
	rustup target install "$cargo_target"
fi

OPENSSL_DIR="$TARGET_PREFIX_DIR" cargo ndk \
	-t "$cargo_ndk_target" \
	-P "$android_api_level" \
	build \
	--release

libssl_archive="target/$cargo_target/release/libssl.a"
require_file "$libssl_archive"
install -m 0644 "$libssl_archive" "$TARGET_PREFIX_DIR/lib/libssl.a"
