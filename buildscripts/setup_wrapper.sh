#!/usr/bin/env bash
set -euo pipefail

pushd $(dirname $ANDROID_NDK_LATEST_HOME)
[ -d 26.1.10909125 ] && sudo rm -rf 26.1.10909125
[ -d 27.0.12077973 ] && sudo rm -rf 27.0.12077973
[ -d 28.2.13676358 ] && sudo rm -rf 28.2.13676358
ln -sf $(basename $ANDROID_NDK_LATEST_HOME) 26.1.10909125
ln -sf $(basename $ANDROID_NDK_LATEST_HOME) 27.0.12077973
ln -sf $(basename $ANDROID_NDK_LATEST_HOME) 28.2.13676358
popd

WRAPPER_SRC="$BUILDSCRIPTS_DIR/ndk-wrapper.py"

BIN_DIR="$ANDROID_NDK_LATEST_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin"
WRAPPER_DST="$BIN_DIR/ndk-wrapper.py"

# Copy wrapper into bin (overwrite allowed)
install -m 0755 "$WRAPPER_SRC" "$WRAPPER_DST"
echo "Installed wrapper: $WRAPPER_DST"

shopt -s nullglob

for f in "$BIN_DIR"/aarch64-linux-android*; do
  # Skip backup files themselves
  [[ "$f" == *_ ]] && continue

  bak="${f}_"
  # If backup exists, do nothing
  if [[ -e "$bak" ]]; then
    continue
  fi

  # Backup original
  mv "$f" "$bak"
  # Create symlink with original name pointing to wrapper (relative link is cleaner)
  ln -sf "ndk-wrapper.py" "$f"

done
