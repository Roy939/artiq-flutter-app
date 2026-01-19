# ARTIQ - Cross-Platform Design Application

## Supported Platforms

ARTIQ now runs on **6 platforms**:

### 📱 Mobile
- ✅ Android (5.0+)
- ✅ iOS (11.0+)

### 💻 Desktop
- ✅ Windows (10+)
- ✅ macOS (10.14+)
- ✅ Linux (Ubuntu 20.04+)

### 🌐 Web
- ✅ Chrome, Firefox, Safari, Edge

## Platform Status

| Feature | Android | iOS | Web | Windows | macOS | Linux |
|---------|---------|-----|-----|---------|-------|-------|
| Firebase Auth | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Email/Password | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Google Sign-In | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Offline Storage | ✅ | ✅ | ⚠️ | ⚠️ | ✅ | ⚠️ |
| Drawing Tool | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Sync | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Responsive UI | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

✅ = Fully supported | ⚠️ = Limited support

## Quick Start

### Enable Platform Support

```bash
# Web
flutter config --enable-web

# Windows
flutter config --enable-windows-desktop

# macOS
flutter config --enable-macos-desktop

# Linux
flutter config --enable-linux-desktop
```

### Run on Any Platform

```bash
# Mobile
flutter run -d android
flutter run -d ios

# Desktop
flutter run -d windows
flutter run -d macos
flutter run -d linux

# Web
flutter run -d chrome
```

## Documentation

- **[MULTI_PLATFORM_GUIDE.md](MULTI_PLATFORM_GUIDE.md)** - Complete guide for all platforms
- **[FIREBASE_CONFIGURED.md](FIREBASE_CONFIGURED.md)** - Firebase setup details
- **[QUICKSTART.md](QUICKSTART.md)** - Quick start guide
- **Platform-specific READMEs** in `web/`, `windows/`, `macos/`, `linux/` directories

## Key Features

### Universal Codebase
- Single Dart/Flutter codebase for all platforms
- Platform-specific optimizations where needed
- Responsive UI that adapts to any screen size

### Firebase Integration
- Configured for all platforms
- Unified authentication across devices
- Real-time sync when online

### Offline-First Architecture
- Create and edit designs without internet
- Automatic sync when connection is restored
- Platform-appropriate local storage

### Responsive Design
- Mobile: Touch-optimized compact layout
- Tablet: Balanced medium layout
- Desktop: Wide layout with max 1200px content width

## Building for Production

```bash
# Mobile
flutter build apk --release          # Android
flutter build ios --release          # iOS

# Desktop
flutter build windows --release      # Windows
flutter build macos --release        # macOS
flutter build linux --release        # Linux

# Web
flutter build web --release          # Web
```

## Project Structure

```
artiq_flutter/
├── android/          # Android configuration
├── ios/              # iOS configuration
├── web/              # Web configuration
├── windows/          # Windows configuration
├── macos/            # macOS configuration
├── linux/            # Linux configuration
├── lib/              # Shared Dart code
│   └── src/
│       ├── screens/  # UI screens
│       ├── services/ # Business logic
│       ├── models/   # Data models
│       ├── widgets/  # Reusable widgets
│       └── utils/    # Utilities (including responsive layout)
└── docs/             # Documentation
```

## Firebase Configuration

All platforms are configured with your Firebase project:

- **Project ID**: artiq-1ebb2
- **Android**: google-services.json ✅
- **iOS**: GoogleService-Info.plist ✅
- **macOS**: GoogleService-Info.plist ✅
- **Web**: firebase-config.js ✅
- **Windows**: Uses web config
- **Linux**: Uses web config

## Development Tips

### Hot Reload Works Everywhere
```bash
# Press 'r' for hot reload
# Press 'R' for hot restart
```

### Platform-Specific Code
```dart
import 'dart:io' show Platform;

if (Platform.isAndroid) {
  // Android-specific code
} else if (Platform.isIOS) {
  // iOS-specific code
}
```

### Responsive Layouts
```dart
import 'package:artiq_flutter/src/utils/responsive_layout.dart';

// Check platform
if (ResponsiveLayout.isDesktop(context)) {
  // Desktop layout
} else {
  // Mobile layout
}
```

## Testing

### Run Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter drive --target=test_driver/app.dart
```

## Deployment

### Mobile App Stores
- **Google Play**: Android APK/AAB
- **Apple App Store**: iOS IPA

### Web Hosting
- **Firebase Hosting**
- **Netlify**
- **Vercel**
- **GitHub Pages**

### Desktop Distribution
- **Windows**: MSIX installer
- **macOS**: DMG or PKG
- **Linux**: DEB, RPM, or Snap

## Contributing

When adding features, ensure they work across all platforms:
1. Test on at least 2 platforms (mobile + desktop or web)
2. Use responsive layout helpers
3. Handle platform-specific cases gracefully
4. Update documentation

## Support

- **Issues**: Report platform-specific issues with platform tag
- **Documentation**: See MULTI_PLATFORM_GUIDE.md
- **Flutter**: https://flutter.dev/docs
- **Firebase**: https://firebase.google.com/docs

## License

Copyright © 2026 ARTIQ. All rights reserved.

---

**Built with Flutter** 💙 | **Powered by Firebase** 🔥 | **Runs Everywhere** 🌍
