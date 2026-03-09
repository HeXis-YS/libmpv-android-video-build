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

ensure_meson
ensure_dir "$DEPS_DIR"
pushd "$DEPS_DIR" >/dev/null

clone_repo "mpv" "release/$v_mpv" "https://github.com/HeXis-YS/mpv.git" &
clone_repo "ffmpeg" "n$v_ffmpeg" "https://github.com/FFmpeg/FFmpeg.git" &
clone_repo "mbedtls" "v$v_mbedtls" "https://github.com/Mbed-TLS/mbedtls.git" --recurse-submodules --shallow-submodules &
clone_repo "libwebp" "v$v_libwebp" "https://github.com/webmproject/libwebp.git" &
clone_repo "libplacebo" "v$v_libplacebo" "https://code.videolan.org/videolan/libplacebo.git" --recurse-submodules --shallow-submodules &
clone_repo "media-kit-android-helper" "main" "https://github.com/media-kit/media-kit-android-helper.git" &
clone_repo "media_kit" "version_1.2.5" "https://github.com/bggRGjQaUbCoE/media-kit.git" &

if is_enabled "ENABLE_DAV1D"; then
	clone_repo "dav1d" "$v_dav1d" "https://code.videolan.org/videolan/dav1d.git" &
fi

if is_enabled "ENABLE_VULKAN"; then
	# shaderc is provided by the NDK source tree and does not need cloning.
	ensure_dir "shaderc"
fi

wait
popd >/dev/null
