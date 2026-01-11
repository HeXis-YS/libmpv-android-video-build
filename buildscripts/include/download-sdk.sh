#!/bin/bash -e

. ./include/depinfo.sh

. ./include/path.sh

[ -z "$TRAVIS" ] && TRAVIS=0 # skip steps not required for CI?
[ -z "$WGET" ] && WGET=wget # possibility of calling wget differently

set -euo pipefail

if [ $TRAVIS -eq 0 ]; then
	hash yum &>/dev/null && {
		sudo yum install autoconf pkgconfig libtool ninja-build unzip \
		python3-pip python3-setuptools unzip wget;
		python3 -m pip install meson jsonschema jinja2; }
	apt-get -v &>/dev/null && {
	    sudo apt-get update;
		sudo apt-get install -y autoconf pkg-config libtool ninja-build nasm unzip \
		python3-pip python3-setuptools unzip;
		python3 -m pip install meson jsonschema jinja2; }
fi

if ! javac -version &>/dev/null; then
	echo "Error: missing Java Development Kit."
	hash yum &>/dev/null && \
		echo "Install it using e.g. sudo yum install java-latest-openjdk-devel"
	apt-get -v &>/dev/null && \
		echo "Install it using e.g. sudo apt-get install default-jre-headless"
	exit 255
fi

mkdir -p sdk && cd sdk

# Android SDK
if [ ! -d "android-sdk-linux" ]; then
	$WGET "https://dl.google.com/android/repository/commandlinetools-linux-${v_sdk}.zip"
	mkdir "android-sdk-linux"
	unzip -q -d "android-sdk-linux" "commandlinetools-linux-${v_sdk}.zip"
	rm "commandlinetools-linux-${v_sdk}.zip"
fi
sdkmanager () {
	local exe="./android-sdk-linux/cmdline-tools/latest/bin/sdkmanager"
	[ -x "$exe" ] || exe="./android-sdk-linux/cmdline-tools/bin/sdkmanager"
	"$exe" --sdk_root="${ANDROID_HOME}" "$@"
}
echo y | sdkmanager \
	"platforms;${v_platform}" \
	"build-tools;${v_sdk_build_tools}" \
	"ndk;${v_ndk}" \
	"cmake;${v_cmake}"

# gas-preprocessor
mkdir -p bin
$WGET "https://github.com/FFmpeg/gas-preprocessor/raw/master/gas-preprocessor.pl" \
	-O bin/gas-preprocessor.pl
chmod +x bin/gas-preprocessor.pl

cd ..
