# macOS Desktop Build

This directory contains the macOS desktop build configuration for ARTIQ.

## Prerequisites

To build for macOS, you need:
- macOS 10.14 (Mojave) or later
- Xcode 13 or later
- CocoaPods
- Flutter SDK with macOS desktop support enabled

## Enable macOS Desktop Support

```bash
flutter config --enable-macos-desktop
```

## Install Dependencies

```bash
cd macos
pod install
cd ..
```

## Building

From the project root:

```bash
flutter build macos
```

## Running

```bash
flutter run -d macos
```

## Firebase Configuration

The Firebase configuration is already set up in `Runner/GoogleService-Info.plist`. The app uses the same Firebase project as the iOS app.

## Google Sign-In

Google Sign-In on macOS uses the OAuth client ID configured in `Info.plist`. The URL scheme is already set up to handle authentication callbacks.

## Notes

- macOS apps require proper entitlements for network access
- The bundle identifier is set to `com.artiq.app`
- Firebase pods will be automatically installed via CocoaPods
