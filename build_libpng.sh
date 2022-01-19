#!/bin/bash
set -euxo pipefail

# Required with Xcode 12 beta:
export M4=$(xcrun -f m4)
OSX_SDKROOT=$(xcrun --sdk macosx --show-sdk-path)
IOS_SDKROOT=$(xcrun --sdk iphoneos --show-sdk-path)
SIM_SDKROOT=$(xcrun --sdk iphonesimulator --show-sdk-path)

curl -OL https://download.sourceforge.net/libpng/libpng-1.6.37.tar.gz
tar xzf libpng-1.6.37.tar.gz
rm libpng-1.6.37.tar.gz
export DYLD_ROOT_PATH\=$(xcrun --sdk iphonesimulator --show-sdk-path)

# libpng

binary=libpng

pushd libpng-1.6.37
if [[ -e Makefile ]]; then make distclean; fi
./configure CC=clang CXX=clang++ \
	CFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT} -fembed-bitcode" \
	CPPFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT} -fembed-bitcode" \
	CXXFLAGS="-arch arm64 -miphoneos-version-min=11.0 -isysroot ${IOS_SDKROOT} -fembed-bitcode" \
	--host=arm-apple-darwin
make -j8
# We're going to need them:
mkdir -p ../libheif/lib_iphoneos
mkdir -p ../libheif/include_iphoneos
cp .libs/libpng16.16.dylib ../libheif/lib_iphoneos/libpng.dylib 
cp png.h pnglibconf.h pngconf.h  ../libheif/include_iphoneos/
# Library is now in: .libs/libpng16.16.dylib. Create framework:
popd

FRAMEWORK_DIR=build/Release-iphoneos/$binary.framework
rm -rf ${FRAMEWORK_DIR}
mkdir -p ${FRAMEWORK_DIR}
mkdir -p ${FRAMEWORK_DIR}/Headers
cp libpng-1.6.37/png.h ${FRAMEWORK_DIR}/Headers
cp libpng-1.6.37/pnglibconf.h ${FRAMEWORK_DIR}/Headers
cp libpng-1.6.37/pngconf.h ${FRAMEWORK_DIR}/Headers
cp libpng-1.6.37/.libs/libpng16.16.dylib ${FRAMEWORK_DIR}/$binary
cp basic_Info.plist ${FRAMEWORK_DIR}/Info.plist
plutil -replace CFBundleExecutable -string $binary ${FRAMEWORK_DIR}/Info.plist
plutil -replace CFBundleName -string $binary ${FRAMEWORK_DIR}/Info.plist
plutil -replace CFBundleIdentifier -string Nicolas-Holzschuch.$binary  ${FRAMEWORK_DIR}/Info.plist
install_name_tool -id @rpath/$binary.framework/$binary   ${FRAMEWORK_DIR}/$binary

export DYLIB_INSTALL_NAME_BASE = @rpath
pushd libpng-1.6.37
if [[ -e Makefile ]]; then make distclean; fi
./configure CC=clang CXX=clang++ \
	CFLAGS="-arch arm64 -mios-simulator-version-min=11.0 -isysroot ${SIM_SDKROOT} -fembed-bitcode" \
	CPPFLAGS="-arch arm64 -mios-simulator-version-min=11.0 -isysroot ${SIM_SDKROOT} -fembed-bitcode" \
	CXXFLAGS="-arch arm64 -mios-simulator-version-min=11.0 -isysroot ${SIM_SDKROOT} -fembed-bitcode" \
	--host=arm-apple-darwin
make -j8
# We're going to need them:
mkdir -p ../libheif/lib_iphonesimulator
mkdir -p ../libheif/include_iphonesimulator
cp .libs/libpng16.16.dylib ../libheif/lib_iphonesimulator/libpng.dylib 
cp png.h pnglibconf.h pngconf.h  ../libheif/include_iphonesimulator/
popd

FRAMEWORK_DIR=build/Release-iphonesimulator/$binary.framework
rm -rf ${FRAMEWORK_DIR}
mkdir -p ${FRAMEWORK_DIR}
mkdir -p ${FRAMEWORK_DIR}/Headers
cp libpng-1.6.37/png.h ${FRAMEWORK_DIR}/Headers
cp libpng-1.6.37/pnglibconf.h ${FRAMEWORK_DIR}/Headers
cp libpng-1.6.37/pngconf.h ${FRAMEWORK_DIR}/Headers
cp libpng-1.6.37/.libs/libpng16.16.dylib ${FRAMEWORK_DIR}/$binary
cp basic_Info_Simulator.plist ${FRAMEWORK_DIR}/Info.plist
plutil -replace CFBundleExecutable -string $binary ${FRAMEWORK_DIR}/Info.plist
plutil -replace CFBundleName -string $binary ${FRAMEWORK_DIR}/Info.plist
plutil -replace CFBundleIdentifier -string Nicolas-Holzschuch.$binary  ${FRAMEWORK_DIR}/Info.plist
install_name_tool -id @rpath/$binary.framework/$binary   ${FRAMEWORK_DIR}/$binary


