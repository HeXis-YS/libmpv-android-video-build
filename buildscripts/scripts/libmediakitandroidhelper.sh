#!/usr/bin/env bash
set -euo pipefail

helper_src="$DEPS_DIR/media-kit-android-helper/app/src/main/cpp/native-lib.cpp"
target_lib_dir="$BUILD_DIR/output/lib/$prefix_name"

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
