#!/usr/bin/env bash
set -euo pipefail

export BUILDSCRIPTS_DIR="${BUILDSCRIPTS_DIR:-$(realpath "$(dirname "${BASH_SOURCE[0]}")")}"
source "$BUILDSCRIPTS_DIR/include/path.sh"
source "$BUILDSCRIPTS_DIR/include/common.sh"

readonly TARGET_ABI="arm64-v8a"
readonly OUTPUT_JAR="$BUILD_DIR/output/default-$TARGET_ABI.jar"

insert_abi_filter() {
	local gradle_file="$1"
	local abi="$2"

	[[ -f "$gradle_file" ]] || die "Gradle file not found: $gradle_file"
	if grep -q "abiFilters" "$gradle_file"; then
		return
	fi

	awk -v abi="$abi" '
	/android \{/ && inserted == 0 {
		print
		print "    defaultConfig {"
		print "        ndk {"
		print "            abiFilters \"" abi "\""
		print "        }"
		print "    }"
		inserted = 1
		next
	}
	{ print }
	' "$gradle_file" >"$gradle_file.tmp"
	mv "$gradle_file.tmp" "$gradle_file"
}

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
	export PATH="$(realpath deps/flutter/bin):$PATH"
	"$BUILDSCRIPTS_DIR/patch.sh"
	"$BUILDSCRIPTS_DIR/setup_wrapper.sh"
	"$BUILDSCRIPTS_DIR/build.sh"
	popd >/dev/null
}

build_media_kit_helper() {
	local helper_dir="$DEPS_DIR/media-kit-android-helper"
	local helper_apk_dir="app/build/outputs/apk/release"
	local output_lib_dir="$ROOT_DIR/libmpv/src/main/jniLibs/$TARGET_ABI"

	pushd "$helper_dir" >/dev/null
	chmod +x gradlew
	# This project does not support command-line ABI filtering reliably.
	./gradlew assembleRelease
	unzip -q -o "$helper_apk_dir/app-release.apk" -d "$helper_apk_dir"
	ensure_dir "$output_lib_dir"
	cp "$helper_apk_dir/lib/$TARGET_ABI/libmediakitandroidhelper.so" "$output_lib_dir/"
	popd >/dev/null
}

build_media_kit_event_loop_jar() {
	local event_loop_dir="$DEPS_DIR/media_kit/media_kit_native_event_loop"
	local example_apk_dir="build/app/outputs/apk/release"

	pushd "$event_loop_dir" >/dev/null
	flutter create --org com.alexmercerind --template plugin_ffi --platforms=android .

	if ! grep -q "ffiPlugin: true" pubspec.yaml; then
		printf "      android:\n        ffiPlugin: true\n" >>pubspec.yaml
	fi
	flutter pub get

	insert_abi_filter "android/build.gradle" "$TARGET_ABI"
	ensure_dir "src/include"
	cp -a "$DEPS_DIR/mpv/include/mpv/." "src/include/"

	pushd example >/dev/null
	flutter clean
	flutter build apk --release --target-platform android-arm64
	unzip -q -o "$example_apk_dir/app-release.apk" -d "$example_apk_dir"

	pushd "$example_apk_dir" >/dev/null
	rm -f lib/*/libapp.so lib/*/libflutter.so
	ensure_dir "$BUILD_DIR/output"
	zip -q -r "$OUTPUT_JAR" "lib/$TARGET_ABI"
	popd >/dev/null

	popd >/dev/null
	popd >/dev/null
}

main() {
	prepare_workspace
	build_native_components
	build_media_kit_helper
	build_media_kit_event_loop_jar
}

main "$@"
