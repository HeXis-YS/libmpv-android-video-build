#!/usr/bin/env bash
set -euo pipefail

export BUILDSCRIPTS_DIR="${BUILDSCRIPTS_DIR:-$(realpath "$(dirname "${BASH_SOURCE[0]}")")}"
source "$BUILDSCRIPTS_DIR/include/path.sh"
source "$BUILDSCRIPTS_DIR/include/common.sh"
source "$BUILDSCRIPTS_DIR/include/depinfo.sh"

declare -A BUILT_TARGETS=()
declare -A ACTIVE_TARGETS=()

prepare_workspace() {
	rm -rf "$DEPS_DIR" "$PREFIX_DIR" "$BUILD_DIR/output"
	ensure_dir "$DEPS_DIR" "$PREFIX_DIR"
}

prepare_dependencies() {
	"$BUILDSCRIPTS_DIR/download.sh"
	"$BUILDSCRIPTS_DIR/patch.sh"
	"$BUILDSCRIPTS_DIR/setup_wrapper.sh"
}

load_arch() {
	unset CC CXX CPATH LIBRARY_PATH C_INCLUDE_PATH CPLUS_INCLUDE_PATH

	local api_level="${ANDROID_API_LEVEL:-24}"
	local target_abi="arm64-v8a"

	export ndk_suffix="-arm64"
	export ndk_triple="aarch64-linux-android"
	local cc_triple="${ndk_triple}${api_level}"
	export build_dir="_build${ndk_suffix}"
	export TARGET_PREFIX_DIR="${PREFIX_DIR}/${target_abi}"
	export TARGET_ABI="$target_abi"
	export TARGET_LIB_DIR="$BUILD_DIR/output/lib/$TARGET_ABI"

	export CC="${cc_triple}-clang"
	export CXX="${cc_triple}-clang++"
	export AS="$CC"
	export AR="llvm-ar"
	export NM="llvm-nm"
	export RANLIB="llvm-ranlib"

	export _CMAKE="env NDK_WRAPPER_DISABLED=1 cmake -B $build_dir -S . -G Ninja -DCMAKE_PREFIX_PATH=$TARGET_PREFIX_DIR -DCMAKE_BUILD_TYPE=Release"
	export _MESON="env NDK_WRAPPER_DISABLED=1 meson setup $build_dir --cross-file $TARGET_PREFIX_DIR/crossfile.txt"
	export _MAKE="make -j$(nproc)"
	export _NINJA="ninja -j$(nproc) -C $build_dir"

	export PKG_CONFIG_SYSROOT_DIR="$TARGET_PREFIX_DIR"
	export PKG_CONFIG_LIBDIR="$PKG_CONFIG_SYSROOT_DIR/lib/pkgconfig"
	unset PKG_CONFIG_PATH
}

setup_prefix() {
	ensure_dir "$TARGET_PREFIX_DIR"
	ensure_dir "$TARGET_LIB_DIR"

	# Enforce flat prefix structure (/usr/local -> /).
	[[ -e "$TARGET_PREFIX_DIR/usr" ]] || ln -s . "$TARGET_PREFIX_DIR/usr"
	[[ -e "$TARGET_PREFIX_DIR/local" ]] || ln -s . "$TARGET_PREFIX_DIR/local"

	local cpu_family="${ndk_triple%%-*}"

	# Meson needs this cross file to avoid host auto-detection.
	cat >"$TARGET_PREFIX_DIR/crossfile.txt" <<CROSSFILE
[built-in options]
buildtype = 'release'
default_library = 'static'
wrap_mode = 'nodownload'
b_ndebug = 'true'
[binaries]
c = '$CC'
cpp = '$CXX'
ar = '$AR'
nm = '$NM'
ranlib = '$RANLIB'
strip = 'llvm-strip -s'
pkg-config = 'pkg-config'
[host_machine]
system = 'android'
cpu_family = '$cpu_family'
cpu = '${CC%%-*}'
endian = 'little'
CROSSFILE
}

build_target() {
	local target="$1"
	local target_dir="$DEPS_DIR/$target"
	local script_path="$BUILDSCRIPTS_DIR/scripts/$target.sh"

	if [[ -n "${BUILT_TARGETS[$target]:-}" ]]; then
		return
	fi
	if [[ -n "${ACTIVE_TARGETS[$target]:-}" ]]; then
		die "Dependency cycle detected on target: $target"
	fi
	[[ -f "$script_path" ]] || die "Build script missing: $script_path"

	ACTIVE_TARGETS[$target]=1

	local deps_var="dep_${target//-/_}[@]"
	local deps=()
	local deps_line="${!deps_var-}"
	if [[ -n "$deps_line" ]]; then
		read -r -a deps <<<"$deps_line"
	fi

	log_info "Preparing $target..."
	if [[ "${#deps[@]}" -eq 0 ]]; then
		echo >&2 "Dependencies: <none>"
	else
		echo >&2 "Dependencies: ${deps[*]}"
	fi
	for dep in "${deps[@]}"; do
		build_target "$dep"
	done

	log_info "Building $target..."
	if [[ -d "$target_dir" ]]; then
		run_in_dir "$target_dir" "$script_path"
	else
		log_info "Using virtual target: $(basename "${script_path%.sh}")"
		"$script_path"
	fi

	unset "ACTIVE_TARGETS[$target]"
	BUILT_TARGETS[$target]=1
}

build_native_components() {
	load_arch
	setup_prefix
	build_target "${BUILD_TARGET:-libmedia_kit_native_event_loop}"
}

main() {
	prepare_workspace
	prepare_dependencies
	build_native_components
	"$BUILDSCRIPTS_DIR/pack.sh"
}

main "$@"
