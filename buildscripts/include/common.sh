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

ensure_dir() {
	mkdir -p "$1"
}

require_file() {
	[[ -f "$1" ]] || die "File not found: $1"
}

require_dir() {
	[[ -d "$1" ]] || die "Directory not found: $1"
}

run_in_dir() {
	local dir="$1"
	shift
	pushd "$dir" >/dev/null
	"$@"
	popd >/dev/null
}
