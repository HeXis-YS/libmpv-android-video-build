#!/usr/bin/env bash
set -euo pipefail

event_loop_src="$DEPS_DIR/media_kit/media_kit_native_event_loop/src/media_kit_native_event_loop.cc"
target_lib_dir="$BUILD_DIR/output/lib/$prefix_name"
compat_include_root="$BUILD_DIR/output/include-compat/$prefix_name"
mpv_include_root="$DEPS_DIR/include"
mpv_client_dir="$DEPS_DIR/include/mpv"
include_args=()

[[ -f "$event_loop_src" ]] || {
	echo "Missing source file: $event_loop_src" >&2
	exit 1
}

if [[ ! -f "$mpv_client_dir/client.h" ]]; then
	echo "Missing mpv header: $mpv_client_dir/client.h" >&2
	exit 1
fi

mkdir -p "$target_lib_dir"
mkdir -p "$compat_include_root"
# Some event-loop sources use #include "include/client.h".
ln -sfn "$mpv_client_dir" "$compat_include_root/include"
include_args+=("-I$mpv_include_root")
include_args+=("-I$compat_include_root")

"$CXX" "$event_loop_src" \
	-std=c++17 \
	-shared \
	-Wl,-z,max-page-size=16384 \
	"${include_args[@]}" \
	-L"$target_lib_dir" \
	-lmpv \
	-lmediakitandroidhelper \
	-static-libstdc++ \
	-o "$target_lib_dir/libmedia_kit_native_event_loop.so"
