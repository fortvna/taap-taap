# Download and install

Download the app assets from [GitHub Releases](https://github.com/fortvna/taap-taap/releases). Expand **Assets** under the release. GitHub's automatic “Source code” archives contain the project, not an app.

## Mac (macOS 14 or newer)

Download **TaapTaap-macOS-universal.zip**, unzip it, and drag **TaapTaap.app** to Applications. It supports both Apple Silicon and Intel Macs.

This preview is ad-hoc signed, not Developer ID signed or notarized. macOS may block the first launch. If you trust this release, attempt to open it, then use **System Settings → Privacy & Security → Open Anyway** and follow the confirmation prompt. Do not disable Gatekeeper globally. Managed Macs may disallow this preview.

## iPhone and iPad (iOS/iPadOS 17 or newer)

**TaapTaap-iOS-iPadOS-unsigned.ipa** is a device app package for developers who will sign it themselves. It cannot be installed by tapping the download. A valid signing identity and provisioning profile are required; no Apple distribution credentials are bundled.

To run on your own device with Xcode: clone the release tag, install XcodeGen, run `./scripts/setup_xcode.sh`, choose the **TaapTaap** scheme, select your Apple signing team and connected device, then Run. Xcode personal-team provisioning is subject to Apple's limits. TestFlight/App Store distribution requires Apple Developer Program signing and App Store Connect setup.

## iPhone/iPad Simulator on a Mac

Download **TaapTaap-iOS-Simulator.zip**, unzip it, and boot an iOS 17+ simulator in Xcode. Drag the extracted app into the simulator, or run:

```sh
xcrun simctl install booted /path/to/TaapTaap.app
xcrun simctl launch booted com.fortvna.taaptaap
```

The simulator package includes Apple Silicon and Intel architectures. It does not run directly on an iPhone or iPad.

## Verify downloads

Download all assets into one folder, then run `shasum -a 256 -c SHA256SUMS.txt` there. Each app and `INSTALL.md` should report `OK`.
