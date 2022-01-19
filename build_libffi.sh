#!/bin/bash
set -euxo pipefail

# Currently, libffi and libzmq scripts produce static libraries. 
# libffi:
pushd libffi
./autogen.sh
python3 generate-darwin-source-and-headers.py --only-ios
xcodebuild -project libffi.xcodeproj -target libffi-iOS -sdk iphoneos -arch arm64 -configuration Debug -quiet
xcodebuild -project libffi.xcodeproj -target libffi-iOS -sdk iphonesimulator -arch arm64 -configuration Debug -quiet
# Python also need ffi_common.h and fficonfig.h
cp build_iphoneos-arm64/fficonfig.h build/Debug-iphoneos/include/ffi/
cp include/ffi_common.h build/Debug-iphoneos/include/ffi/ 
cp build_iphonesimulator-x86_64/fficonfig.h build/Debug-iphonesimulator/include/ffi/
cp include/ffi_common.h build/Debug-iphonesimulator/include/ffi/
popd 
# then, merge them into XCframeworks:
framework=libffi
rm -rf $framework.xcframework
xcodebuild -create-xcframework \
	-library $framework/build/Debug-iphoneos/libffi.a -headers $framework/build/Debug-iphoneos/include \
	-library $framework/build/Debug-iphonesimulator/libffi.a -headers $framework/build/Debug-iphonesimulator/include \
	-output $framework.xcframework

