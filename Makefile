.PHONY: test xcodegen xcode-open xcode-setup build-ios build-mac

test:
	swift test

xcodegen:
	xcodegen generate --spec project.yml

xcode-open: xcodegen
	open TaapTaap.xcodeproj

xcode-setup:
	./scripts/setup_xcode.sh

build-ios: xcodegen
	xcodebuild -project TaapTaap.xcodeproj -scheme TaapTaap -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build

build-mac: xcodegen
	xcodebuild -project TaapTaap.xcodeproj -scheme TaapTaapMac -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO build
