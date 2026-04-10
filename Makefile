.PHONY: test xcodegen xcode-open xcode-setup

test:
swift test

xcodegen:
xcodegen generate --spec project.yml

xcode-open: xcodegen
open TaapTaap.xcodeproj

xcode-setup:
./scripts/setup_xcode.sh
