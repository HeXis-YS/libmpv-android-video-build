#!/usr/bin/env bash
set -euo pipefail

export BUILDSCRIPTS_DIR="${BUILDSCRIPTS_DIR:-$(realpath "$(dirname "${BASH_SOURCE[0]}")")}"
source "$BUILDSCRIPTS_DIR/include/path.sh"
source "$BUILDSCRIPTS_DIR/include/common.sh"
source "$BUILDSCRIPTS_DIR/include/depinfo.sh"

ensure_meson() {
	if command -v meson >/dev/null 2>&1; then
		return
	fi
	log_info "Installing meson..."
	python3 -m pip install meson
}

clone_repo() {
	local dest="$1"
	local branch="$2"
	local url="$3"
	shift 3

	git clone --depth 1 --single-branch --no-tags -b "$branch" "$@" "$url" "$dest"
}

queue_clone() {
	clone_repo "$@" &
}

queue_default_repos() {
	queue_clone "mpv" "v$v_mpv" "https://github.com/mpv-player/mpv.git"
	queue_clone "ffmpeg" "n$v_ffmpeg" "https://github.com/FFmpeg/FFmpeg.git"
	queue_clone "mbedtls" "v$v_mbedtls" "https://github.com/Mbed-TLS/mbedtls.git" --recurse-submodules --shallow-submodules
	queue_clone "libwebp" "v$v_libwebp" "https://github.com/webmproject/libwebp.git"
	queue_clone "libass" "$v_libass" "https://github.com/libass/libass.git"
	queue_clone "freetype" "VER-$v_freetype" "https://gitlab.freedesktop.org/freetype/freetype.git"
	queue_clone "fribidi" "v$v_fribidi" "https://github.com/fribidi/fribidi.git"
	queue_clone "harfbuzz" "$v_harfbuzz" "https://github.com/harfbuzz/harfbuzz.git"
	queue_clone "libplacebo" "v$v_libplacebo" "https://code.videolan.org/videolan/libplacebo.git" --recurse-submodules --shallow-submodules
	queue_clone "media-kit-android-helper" "main" "https://github.com/media-kit/media-kit-android-helper.git"
	queue_clone "media_kit" "version_1.2.5" "https://github.com/bggRGjQaUbCoE/media-kit.git"
}

queue_optional_repos() {
	if is_enabled "ENABLE_DAV1D"; then
		queue_clone "dav1d" "$v_dav1d" "https://code.videolan.org/videolan/dav1d.git"
	fi

	if is_enabled "ENABLE_VULKAN"; then
		# shaderc is provided by the NDK source tree and does not need cloning.
		ensure_dir "$DEPS_DIR/shaderc"
	fi
}

download_all_repos() {
	queue_default_repos
	queue_optional_repos
	wait
}

ensure_meson
ensure_dir "$DEPS_DIR"

run_in_dir "$DEPS_DIR" download_all_repos
