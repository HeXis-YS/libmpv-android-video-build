#!/usr/bin/env bash
set -euo pipefail

export BUILDSCRIPTS_DIR="${BUILDSCRIPTS_DIR:-$(realpath "$(dirname "${BASH_SOURCE[0]}")")}"
source "$BUILDSCRIPTS_DIR/include/path.sh"
source "$BUILDSCRIPTS_DIR/include/common.sh"

readonly TARGET_ABI="${TARGET_ABI:-arm64-v8a}"
readonly TARGET_LIB_DIR="$BUILD_DIR/output/lib/$TARGET_ABI"
readonly PREFIX_LIB_DIR="$PREFIX_DIR/$TARGET_ABI/lib"
readonly OUTPUT_JAR="$BUILD_DIR/output/default-$TARGET_ABI.jar"

prepare_workspace() {
	ensure_dir "$BUILD_DIR"
	rm -rf "$DEPS_DIR" "$PREFIX_DIR" "$BUILD_DIR/output"
	ensure_dir "$DEPS_DIR"
	ensure_dir "$PREFIX_DIR"
}

run_pipeline_step() {
	local step="$1"
	run_in_dir "$BUILD_DIR" "$BUILDSCRIPTS_DIR/$step"
}

build_native_components() {
	local step
	for step in download.sh patch.sh setup_wrapper.sh build.sh; do
		run_pipeline_step "$step"
	done
}

stage_shared_objects() {
	local so_path
	local so_file_count

	require_dir "$PREFIX_LIB_DIR"
	require_file "$TARGET_LIB_DIR/libmediakitandroidhelper.so"
	require_file "$TARGET_LIB_DIR/libmedia_kit_native_event_loop.so"

	# Include mpv and dependency shared objects in the final jar.
	while IFS= read -r -d '' so_path; do
		cp -aL "$so_path" "$TARGET_LIB_DIR/"
	done < <(find "$PREFIX_LIB_DIR" -maxdepth 1 -type f -name "lib*.so*" -print0)

	so_file_count="$(find "$TARGET_LIB_DIR" -maxdepth 1 -type f -name "*.so*" | wc -l)"
	if [[ "$so_file_count" -eq 0 ]]; then
		die "No shared objects found in $TARGET_LIB_DIR; refusing to create empty jar."
	fi
}

package_output_jar() {
	require_dir "$TARGET_LIB_DIR"
	ensure_dir "$BUILD_DIR/output"
	rm -f "$OUTPUT_JAR"
	run_in_dir "$BUILD_DIR/output" zip -q -r "$(basename "$OUTPUT_JAR")" "lib/$TARGET_ABI"
}

main() {
	prepare_workspace
	build_native_components
	stage_shared_objects
	package_output_jar
}

main "$@"
