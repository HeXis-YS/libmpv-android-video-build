#!/bin/bash -e

application_mk=$PWD/../../../app/src/main/jni/Application.mk # APP_{PLATFORM,STL} are imported from here

abi=arm64-v8a

# build using the NDK's scripts, but keep object files in our build dir
pushd $ANDROID_NDK_LATEST_HOME/sources/third_party/shaderc

ndk-build -j$(nproc) \
	NDK_PROJECT_PATH=. \
	APP_BUILD_SCRIPT=Android.mk \
	APP_PLATFORM=android-24 \
	APP_STL=c++_shared \
	APP_ABI=$abi \
	NDK_APP_OUT="$build_dir" \
	NDK_APP_LIBS_OUT="$build_dir/libs" \
	libshaderc_combined

pushd $build_dir
cp -vr include/* "$prefix_dir/include"
cp -v libs/*/$abi/libshaderc.a "$prefix_dir/lib/libshaderc_combined.a"
popd

popd

# create a pkgconfig file
# The /usr/local references may look redundant but are needed to force pkg-config
# to emit the sysroot include or lib path at least one (or it wouldn't work).
mkdir -p "$prefix_dir"/lib/pkgconfig
cat >"$prefix_dir"/lib/pkgconfig/shaderc_combined.pc <<"END"
Name: shaderc_combined
Description:
Version: 2022.3-unknown
Libs: -L/usr/local/lib -lshaderc_combined
Cflags: -I/usr/local/include
END

if [ -z "$(pkg-config --cflags shaderc_combined)" ]; then
	echo >&2 "shaderc pkg-config sanity check failed"
	exit 1
fi
