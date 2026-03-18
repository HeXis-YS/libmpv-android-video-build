#!/bin/bash -e
: "${BUILDSCRIPTS_DIR:?BUILDSCRIPTS_DIR is not set}"
source "$BUILDSCRIPTS_DIR/include/common.sh"

DAV1D_CONFIG=
if [ -n "$ENABLE_DAV1D" ]; then
	DAV1D_CONFIG="--enable-libdav1d --enable-decoder=libdav1d"
fi
: "${TARGET_PREFIX_DIR:?TARGET_PREFIX_DIR is not set}"

# --enable-protocol=udp is required by OpenSSL or FFmprg 8.1+
TLS_CONFIG=--enable-mbedtls
if [ "$(tls_backend)" = "openssl" ]; then
	TLS_CONFIG="--enable-openssl --enable-protocol=udp"
fi

mkdir -p $build_dir
pushd $build_dir

cpu=armv8-a

NDK_WRAPPER_DISABLED=1 ../configure \
	--target-os=android \
	--enable-cross-compile \
	--cross-prefix=$ndk_triple- \
	--cc=$CC \
	--ar=$AR \
	--nm=$NM \
	--ranlib=$RANLIB \
	--arch=${ndk_triple%%-*} \
	--cpu=$cpu \
	--pkg-config=pkg-config \
	--extra-cflags="-I$TARGET_PREFIX_DIR/include" \
	--extra-ldflags="-L$TARGET_PREFIX_DIR/lib" \
	\
	--enable-version3 \
	--disable-debug \
	--pkg-config-flags=--static \
	\
	--disable-everything \
	--disable-doc \
	--disable-avdevice \
	--disable-programs \
	--disable-swscale-alpha \
	\
	--disable-zlib \
	\
	--enable-jni \
	--enable-pic \
	--enable-optimizations \
	--enable-hardcoded-tables \
	\
	--enable-mediacodec \
	--enable-decoder=h264_mediacodec \
	--enable-decoder=hevc_mediacodec \
	--enable-decoder=av1_mediacodec \
	--enable-decoder=aac_mediacodec \
	--enable-decoder=flac \
	\
	$DAV1D_CONFIG \
	\
	--enable-demuxer=flv \
	--enable-demuxer=mov \
	\
	--enable-decoder=webvtt \
	--enable-demuxer=webvtt \
	\
	--enable-libwebp \
	--enable-muxer=webp \
	--enable-encoder=libwebp \
	--enable-encoder=libwebp_anim \
	\
	--enable-filter=aresample \
	--enable-filter=dynaudnorm \
	--enable-filter=loudnorm \
	\
	$TLS_CONFIG \
	--enable-network \
	--enable-protocol=file \
	--enable-protocol=https \
	--enable-protocol=httpproxy \
	\
	$CUSTOM_FFMPEG_OPTIONS

$_MAKE
DESTDIR="$TARGET_PREFIX_DIR" $_MAKE install

popd
