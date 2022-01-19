#!/bin/bash
set -euxo pipefail

# libzmq:
# create the static libraries

IOS_SDKROOT=$(xcrun --sdk iphoneos --show-sdk-path)
SIM_SDKROOT=$(xcrun --sdk iphonesimulator --show-sdk-path)
IOS_VERSION_MIN=8.0
OTHER_CPPFLAGS="-Os -fembed-bitcode"

pushd libzmq
ZMQ_DIR=$(pwd)
IOS_BUILD_DIR="${ZMQ_DIR}/builds/ios/libzmq_build/arm64-ios"
SIM_BUILD_DIR="${ZMQ_DIR}/builds/ios/libzmq_build/arm64-sim"

if [[ -e Makefile ]]; then make distclean; fi
./autogen.sh

mkdir -p ${IOS_BUILD_DIR}
./configure \
CC=clang CXX=clang++ \
	CFLAGS="-arch arm64 -mios-version-min=${IOS_VERSION_MIN} -isysroot ${IOS_SDKROOT} ${OTHER_CPPFLAGS}" \
	CPPFLAGS="-arch arm64 -mios-version-min=${IOS_VERSION_MIN} -isysroot ${IOS_SDKROOT} ${OTHER_CPPFLAGS}" \
	CXXFLAGS="-arch arm64 -mios-version-min=${IOS_VERSION_MIN} -isysroot ${IOS_SDKROOT} ${OTHER_CPPFLAGS}" \
	--prefix=${IOS_BUILD_DIR} \
	--disable-shared \
	--enable-static \
	--host=arm-apple-darwin \
	--disable-perf \
	--disable-curve-keygen
make -j8 
make install
make clean

mkdir -p ${SIM_BUILD_DIR}
./configure \
	CC=clang CXX=clang++ \
	CFLAGS="-arch arm64 -mios-simulator-version-min=${IOS_VERSION_MIN} -isysroot ${SIM_SDKROOT} ${OTHER_CPPFLAGS}" \
	CPPFLAGS="-arch arm64 -mios-simulator-version-min=${IOS_VERSION_MIN} -isysroot ${SIM_SDKROOT} ${OTHER_CPPFLAGS}" \
	CXXFLAGS="-arch arm64 -mios-simulator-version-min=${IOS_VERSION_MIN} -isysroot ${SIM_SDKROOT} ${OTHER_CPPFLAGS}" \
	--prefix=${SIM_BUILD_DIR} \
	--disable-shared \
	--enable-static \
	--host=arm-apple-darwin \
	--disable-perf \
	--disable-curve-keygen
make -j8 
make install
make clean

popd
# then, merge them into XCframeworks:
framework=libzmq
rm -rf $framework.xcframework
xcodebuild -create-xcframework \
	-library ${IOS_BUILD_DIR}/lib/libzmq.a -headers ${IOS_BUILD_DIR}/include \
	-library ${SIM_BUILD_DIR}/lib/libzmq.a -headers ${SIM_BUILD_DIR}/include \
	-output $framework.xcframework


