#!/usr/bin/env bash
set -euo pipefail

readonly -a NDK_ALIAS_DIRS=(
	"26.1.10909125"
	"27.0.12077973"
	"28.2.13676358"
)

refresh_ndk_aliases() {
	local ndk_parent_dir
	ndk_parent_dir="$(dirname "$ANDROID_NDK_LATEST_HOME")"
	local current_ndk
	current_ndk="$(basename "$ANDROID_NDK_LATEST_HOME")"

	pushd "$ndk_parent_dir" >/dev/null
	for alias in "${NDK_ALIAS_DIRS[@]}"; do
		if [[ -e "$alias" || -L "$alias" ]]; then
			sudo rm -rf "$alias"
		fi
		ln -sfn "$current_ndk" "$alias"
	done
	popd >/dev/null
}

install_wrapper() {
	local wrapper_src="$BUILDSCRIPTS_DIR/ndk-wrapper.py"
	local bin_dir="$ANDROID_NDK_LATEST_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin"
	local wrapper_dst="$bin_dir/ndk-wrapper.py"

	install -m 0755 "$wrapper_src" "$wrapper_dst"
	printf 'Installed wrapper: %s\n' "$wrapper_dst"

	shopt -s nullglob
	for f in "$bin_dir"/aarch64-linux-android*; do
		# Skip already-backed-up files.
		[[ "$f" == *_ ]] && continue

		local bak="${f}_"
		if [[ -e "$bak" ]]; then
			continue
		fi

		mv "$f" "$bak"
		ln -sfn "ndk-wrapper.py" "$f"
	done
}

main() {
	refresh_ndk_aliases
	install_wrapper
}

main "$@"
