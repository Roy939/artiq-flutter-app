# Linux Desktop Build

This directory contains the Linux desktop build configuration for ARTIQ.

## Prerequisites

To build for Linux, you need:
- Linux (Ubuntu 20.04 or later recommended)
- GTK 3.0 development libraries
- Flutter SDK with Linux desktop support enabled

### Install Dependencies (Ubuntu/Debian)

```bash
sudo apt-get update
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
```

## Enable Linux Desktop Support

```bash
flutter config --enable-linux-desktop
```

## Building

From the project root:

```bash
flutter build linux
```

## Running

```bash
flutter run -d linux
```

## Firebase Configuration

Firebase for Linux desktop uses the same web-based authentication as other desktop platforms. The app will automatically use the Firebase web configuration.

## Google Sign-In

Google Sign-In on Linux uses a web-based OAuth flow that opens in the default browser.

## Notes

- The Linux build uses GTK 3.0 for the window system
- The application ID is set to `com.artiq.app`
- All Flutter plugins must support Linux to work properly
- The build uses CMake and requires clang compiler
