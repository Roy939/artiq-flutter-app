# Windows Desktop Build

This directory contains the Windows desktop build configuration for ARTIQ.

## Prerequisites

To build for Windows, you need:
- Visual Studio 2022 or later with C++ desktop development workload
- Windows 10 SDK
- Flutter SDK with Windows desktop support enabled

## Enable Windows Desktop Support

```bash
flutter config --enable-windows-desktop
```

## Building

From the project root:

```bash
flutter build windows
```

## Running

```bash
flutter run -d windows
```

## Firebase Configuration

Firebase for Windows desktop uses the same authentication as web. The app will automatically use the Firebase configuration from your project.

## Notes

- The Windows build uses CMake for native code compilation
- All Flutter plugins must support Windows to work properly
- Google Sign-In on Windows uses web-based OAuth flow
