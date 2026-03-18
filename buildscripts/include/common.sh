#!/usr/bin/env bash

log_info() {
	printf >&2 '\e[1;34m%s\e[m\n' "$*"
}

log_error() {
	printf >&2 '\e[1;31m%s\e[m\n' "$*"
}

die() {
	log_error "$*"
	exit 1
}

is_enabled() {
	local var_name="$1"
	[[ -n "${!var_name:-}" ]]
}

tls_backend() {
	local backend="${TLS_LIBRARY:-}"

	if [[ -z "$backend" && -n "${ENABLE_OPENSSL:-}" ]]; then
		backend="openssl"
	fi
	if [[ -z "$backend" ]]; then
		backend="mbedtls"
	fi

	backend="${backend,,}"
	case "$backend" in
	mbedtls | openssl)
		printf '%s\n' "$backend"
		;;
	*)
		die "Unsupported TLS library: $backend (expected: mbedtls or openssl)"
		;;
	esac
}

ensure_dir() {
	mkdir -p "$@"
}

require_file() {
	local path
	for path in "$@"; do
		[[ -f "$path" ]] || die "File not found: $path"
	done
}

require_dir() {
	local path
	for path in "$@"; do
		[[ -d "$path" ]] || die "Directory not found: $path"
	done
}

run_in_dir() {
	local dir="$1"
	shift
	(
		cd "$dir"
		"$@"
	)
}
