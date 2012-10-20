#! /bin/bash

DISTROOT=dist
BUILDROOT=build

xcodebuild install -target AsyncNetwork | egrep "^(===|\*\*)"
mkdir -p $DISTROOT/ios/
cp -Rf $DISTROOT/mac/AsyncNetwork.framework $DISTROOT/ios/AsyncNetwork.framework
xcodebuild build -target AsyncNetworkStatic | egrep "^(===|\*\*)"
xcodebuild build -target AsyncNetworkStatic -sdk iphonesimulator -arch i386 | egrep "^(===|\*\*)"
lipo -o $DISTROOT/ios/AsyncNetwork.framework/Versions/Current/AsyncNetwork\
 -create $BUILDROOT/Release-iphoneos/libAsyncNetwork.a build/Release-iphonesimulator/libAsyncNetwork.a
