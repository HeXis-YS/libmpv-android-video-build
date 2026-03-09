#!/usr/bin/env bash
set -euo pipefail

export BUILDSCRIPTS_DIR="${BUILDSCRIPTS_DIR:-$(realpath "$(dirname "${BASH_SOURCE[0]}")")}"
source "$BUILDSCRIPTS_DIR/include/path.sh"
source "$BUILDSCRIPTS_DIR/include/common.sh"

readonly TARGET_ABI="arm64-v8a"
readonly OUTPUT_JAR="$BUILD_DIR/output/default-$TARGET_ABI.jar"

prepare_workspace() {
	ensure_dir "$BUILD_DIR"
	pushd "$BUILD_DIR" >/dev/null
	rm -rf deps prefix
	ensure_dir deps
	ensure_dir prefix
	popd >/dev/null
}

build_native_components() {
	pushd "$BUILD_DIR" >/dev/null
	"$BUILDSCRIPTS_DIR/download.sh"
	"$BUILDSCRIPTS_DIR/patch.sh"
	"$BUILDSCRIPTS_DIR/setup_wrapper.sh"
	"$BUILDSCRIPTS_DIR/build.sh"
	popd >/dev/null
}

compile_media_kit_shared_objects() {
	local prefix_lib_dir="$PREFIX_DIR/$TARGET_ABI/lib"
	local target_lib_dir="$BUILD_DIR/output/lib/$TARGET_ABI"
	local so_path
	local so_file_count

	[[ -d "$prefix_lib_dir" ]] || die "Missing prefix lib directory: $prefix_lib_dir"
	[[ -f "$target_lib_dir/libmediakitandroidhelper.so" ]] || die "Missing built library: $target_lib_dir/libmediakitandroidhelper.so"
	[[ -f "$target_lib_dir/libmedia_kit_native_event_loop.so" ]] || die "Missing built library: $target_lib_dir/libmedia_kit_native_event_loop.so"

	# Include mpv and dependency shared objects in the final jar.
	while IFS= read -r -d '' so_path; do
		cp -aL "$so_path" "$target_lib_dir/"
	done < <(find "$prefix_lib_dir" -maxdepth 1 -type f -name "lib*.so*" -print0)

	so_file_count="$(find "$target_lib_dir" -maxdepth 1 -type f -name "*.so*" | wc -l)"
	if [[ "$so_file_count" -eq 0 ]]; then
		die "No shared objects found in $target_lib_dir; refusing to create empty jar."
	fi
}

package_output_jar() {
	local staged_lib_dir="$BUILD_DIR/output/lib/$TARGET_ABI"
	[[ -d "$staged_lib_dir" ]] || die "Missing staged library directory: $staged_lib_dir"

	ensure_dir "$BUILD_DIR/output"
	rm -f "$OUTPUT_JAR"
	pushd "$BUILD_DIR/output" >/dev/null
	zip -q -r "$(basename "$OUTPUT_JAR")" "lib/$TARGET_ABI"
	popd >/dev/null
}

main() {
	prepare_workspace
	build_native_components
	compile_media_kit_shared_objects
	package_output_jar
}

main "$@"
