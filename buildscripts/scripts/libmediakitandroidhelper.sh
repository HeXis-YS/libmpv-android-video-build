#!/usr/bin/env bash
set -euo pipefail

: "${DEPS_DIR:?DEPS_DIR is not set}"
: "${BUILD_DIR:?BUILD_DIR is not set}"
: "${TARGET_ABI:?TARGET_ABI is not set}"
: "${CXX:?CXX is not set}"

helper_src="$DEPS_DIR/media-kit-android-helper/app/src/main/cpp/native-lib.cpp"
target_lib_dir="${TARGET_LIB_DIR:-$BUILD_DIR/output/lib/$TARGET_ABI}"

[[ -f "$helper_src" ]] || {
	echo "Missing source file: $helper_src" >&2
	exit 1
}

mkdir -p "$target_lib_dir"

"$CXX" "$helper_src" \
	-shared \
	-Wl,-z,max-page-size=16384 \
	-llog \
	-landroid \
	-static-libstdc++ \
	-o "$target_lib_dir/libmediakitandroidhelper.so"
