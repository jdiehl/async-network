#! /bin/bash

BUILDROOT=build
TEMPROOT=temp

# check out
git submodule init
git submodule update

# build
xcodebuild build -target AsyncNetwork | egrep "^(===|\*\*)"
xcodebuild build -target AsyncNetworkIOS -sdk iphoneos | egrep "^(===|\*\*)"
xcodebuild build -target AsyncNetworkIOS -sdk iphonesimulator | egrep "^(===|\*\*)"

# make distribution copy
mkdir -p $TEMPROOT
cp -rf Examples Icon.png License.txt README.md $BUILDROOT/Release/* $BUILDROOT/Release-iphoneos/*\
 $TEMPROOT
lipo -o $TEMPROOT/AsyncNetworkIOS.framework/AsyncNetworkIOS -create\
 $BUILDROOT/Release-iphoneos/AsyncNetworkIOS.framework/AsyncNetworkIOS\
 $BUILDROOT/Release-iphonesimulator/AsyncNetworkIOS.framework/AsyncNetworkIOS
rm -rf $TEMPROOT/Examples/*/*.xcodeproj/project.xcworkspace
rm -rf $TEMPROOT/Examples/*/*.xcodeproj/xcuserdata

# create disk image
rm -f AsyncNetwork.dmg
hdiutil create -srcfolder $TEMPROOT -fs HFS+ -volname AsyncNetwork AsyncNetwork.dmg

# move frameworks
cp -rf $TEMPROOT/AsyncNetwork* .

# clean up
rm -rf $TEMPROOT