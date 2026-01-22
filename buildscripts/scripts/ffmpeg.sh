#!/bin/bash -e
DAV1D_CONFIG=
if [ -n "$ENABLE_DAV1D" ]; then
	DAV1D_CONFIG="--enable-libdav1d --enable-decoder=libdav1d"
fi

mkdir -p $build_dir
pushd $build_dir

cpu=armv8-a

../configure \
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
	--extra-cflags="-I$prefix_dir/include" \
	--extra-ldflags="-L$prefix_dir/lib" \
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
	--enable-demuxer=hls \
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
	--enable-mbedtls \
	--enable-network \
	--enable-protocol=hls \
	--enable-protocol=https \
	--enable-protocol=httpproxy

$_MAKE
DESTDIR="$prefix_dir" $_MAKE install

popd
