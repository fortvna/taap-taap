#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

mkdir -p dist
build_root="$(mktemp -d "${TMPDIR:-/tmp}/taap-release.XXXXXX")"

# Ad-hoc signing supports local execution on Intel and Apple Silicon Macs.
# It does not provide Developer ID verification or Apple notarization.
xcodebuild -quiet -project TaapTaap.xcodeproj -scheme TaapTaapMac \
  -configuration Release -destination 'generic/platform=macOS' \
  -derivedDataPath "$build_root/mac" ARCHS='arm64 x86_64' ONLY_ACTIVE_ARCH=NO \
  CODE_SIGN_STYLE=Manual CODE_SIGN_IDENTITY=- DEVELOPMENT_TEAM= build
mac_app="$build_root/mac/Build/Products/Release/TaapTaap.app"
lipo "$mac_app/Contents/MacOS/TaapTaap" -verify_arch arm64 x86_64
codesign --verify --deep --strict --verbose=2 "$mac_app"
codesign -d --entitlements :- "$mac_app" > "$build_root/mac-entitlements.plist"
/usr/libexec/PlistBuddy -c 'Print :com.apple.security.app-sandbox' "$build_root/mac-entitlements.plist" | grep -qx true
open "$mac_app"
sleep 3
pgrep -x TaapTaap
pkill -x TaapTaap
ditto -c -k --sequesterRsrc --keepParent "$mac_app" dist/TaapTaap-macOS-universal.zip

xcodebuild -quiet -project TaapTaap.xcodeproj -scheme TaapTaap \
  -configuration Release -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath "$build_root/simulator" ARCHS='arm64 x86_64' ONLY_ACTIVE_ARCH=NO \
  CODE_SIGNING_ALLOWED=NO build
sim_app="$build_root/simulator/Build/Products/Release-iphonesimulator/TaapTaap.app"
lipo "$sim_app/TaapTaap" -verify_arch arm64 x86_64
ditto -c -k --sequesterRsrc --keepParent "$sim_app" dist/TaapTaap-iOS-Simulator.zip

# A device build is useful for developers who supply their own signing identity.
# This archive is deliberately labelled unsigned; it is not directly installable.
xcodebuild -quiet -project TaapTaap.xcodeproj -scheme TaapTaap \
  -configuration Release -destination 'generic/platform=iOS' \
  -derivedDataPath "$build_root/ios" CODE_SIGNING_ALLOWED=NO build
ios_app="$build_root/ios/Build/Products/Release-iphoneos/TaapTaap.app"
lipo "$ios_app/TaapTaap" -verify_arch arm64
mkdir -p "$build_root/device/Payload"
ditto "$ios_app" "$build_root/device/Payload/TaapTaap.app"
ditto -c -k --keepParent "$build_root/device/Payload" dist/TaapTaap-iOS-iPadOS-unsigned.ipa

cp docs/DOWNLOADS.md dist/INSTALL.md
(cd dist && shasum -a 256 ./*.zip ./*.ipa INSTALL.md > SHA256SUMS.txt)
