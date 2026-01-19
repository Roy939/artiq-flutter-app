# ARTIQ Multi-Platform Guide 🚀

Your ARTIQ Flutter project now supports **all major platforms**:
- 📱 **Mobile**: Android & iOS
- 💻 **Desktop**: Windows, macOS & Linux
- 🌐 **Web**: Browser-based application

## Platform Support Overview

| Platform | Status | Firebase Auth | Offline Support | Notes |
|----------|--------|---------------|-----------------|-------|
| Android | ✅ Ready | ✅ Full | ✅ Yes | Uses google-services.json |
| iOS | ✅ Ready | ✅ Full | ✅ Yes | Uses GoogleService-Info.plist |
| Web | ✅ Ready | ✅ Full | ⚠️ Limited | Uses IndexedDB for storage |
| Windows | ✅ Ready | ✅ Web-based | ⚠️ Limited | Requires Visual Studio |
| macOS | ✅ Ready | ✅ Full | ✅ Yes | Requires Xcode |
| Linux | ✅ Ready | ✅ Web-based | ⚠️ Limited | Requires GTK 3.0 |

## Quick Start by Platform

### 📱 Mobile (Android & iOS)

Already configured! See the main README.md for mobile setup instructions.

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios
```

### 🌐 Web

**Enable Web Support:**
```bash
flutter config --enable-web
```

**Run in Browser:**
```bash
flutter run -d chrome
# or
flutter run -d edge
# or
flutter run -d firefox
```

**Build for Production:**
```bash
flutter build web
```

The built files will be in `build/web/` and can be deployed to any web hosting service.

**Firebase Configuration:**
- Web configuration is already set up in `web/firebase-config.js`
- Uses the Firebase Web SDK
- Authentication works via OAuth redirect flow

### 💻 Windows Desktop

**Prerequisites:**
- Windows 10 or later
- Visual Studio 2022 with C++ desktop development workload
- Windows 10 SDK

**Enable Windows Support:**
```bash
flutter config --enable-windows-desktop
```

**Run:**
```bash
flutter run -d windows
```

**Build:**
```bash
flutter build windows
```

The executable will be in `build/windows/runner/Release/`

**Notes:**
- Google Sign-In uses web-based OAuth flow
- Requires internet connection for first-time authentication
- Offline support uses local file storage

### 🍎 macOS Desktop

**Prerequisites:**
- macOS 10.14 (Mojave) or later
- Xcode 13 or later
- CocoaPods

**Enable macOS Support:**
```bash
flutter config --enable-macos-desktop
```

**Install Dependencies:**
```bash
cd macos
pod install
cd ..
```

**Run:**
```bash
flutter run -d macos
```

**Build:**
```bash
flutter build macos
```

The app bundle will be in `build/macos/Build/Products/Release/`

**Firebase Configuration:**
- Uses the same GoogleService-Info.plist as iOS
- Full Firebase SDK support
- Native authentication experience

### 🐧 Linux Desktop

**Prerequisites:**
- Ubuntu 20.04 or later (or equivalent)
- GTK 3.0 development libraries
- Clang compiler

**Install Dependencies (Ubuntu/Debian):**
```bash
sudo apt-get update
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
```

**Enable Linux Support:**
```bash
flutter config --enable-linux-desktop
```

**Run:**
```bash
flutter run -d linux
```

**Build:**
```bash
flutter build linux
```

The executable will be in `build/linux/x64/release/bundle/`

**Notes:**
- Uses web-based Firebase authentication
- Requires internet for authentication
- GTK 3.0 provides native look and feel

## Firebase Configuration by Platform

### Mobile (Android & iOS)
- ✅ **Android**: `android/app/google-services.json` (configured)
- ✅ **iOS**: `ios/Runner/GoogleService-Info.plist` (configured)
- Full Firebase SDK with native features

### Web
- ✅ **Configuration**: `web/firebase-config.js` (configured)
- Uses Firebase JS SDK v9+
- OAuth redirect flow for authentication

### Desktop (Windows, macOS, Linux)
- **Windows**: Uses web-based Firebase auth
- ✅ **macOS**: Uses iOS Firebase config (configured)
- **Linux**: Uses web-based Firebase auth

## Responsive UI

The app automatically adapts to different screen sizes:

- **Mobile** (< 768px): Optimized for touch, compact layout
- **Tablet** (768px - 1024px): Balanced layout with more space
- **Desktop** (> 1024px): Wide layout with max content width of 1200px

The responsive layout is handled by `lib/src/utils/responsive_layout.dart`.

## Platform-Specific Features

### Drawing Tool
- **Mobile**: Touch-optimized with gesture support
- **Desktop**: Mouse/trackpad support with precise control
- **All Platforms**: Vector-based drawing with JSON storage

### Authentication
- **Mobile**: Native Firebase auth with Google Sign-In
- **Web**: OAuth redirect flow
- **Desktop**: Platform-appropriate OAuth flows

### Offline Support
- **Mobile**: Full offline support with SharedPreferences
- **Web**: Limited offline with IndexedDB
- **Desktop**: Platform-dependent local storage

## Building for Production

### Android APK
```bash
flutter build apk --release
```

### iOS App Store
```bash
flutter build ios --release
```

### Web Deployment
```bash
flutter build web --release
# Deploy the build/web/ directory to your hosting service
```

### Windows Installer
```bash
flutter build windows --release
# Use a tool like Inno Setup to create an installer
```

### macOS App Bundle
```bash
flutter build macos --release
# Sign and notarize for distribution
```

### Linux Package
```bash
flutter build linux --release
# Create .deb or .rpm package using platform tools
```

## Testing on Different Platforms

### List Available Devices
```bash
flutter devices
```

### Run on Specific Device
```bash
flutter run -d <device-id>
```

### Common Device IDs
- `chrome` - Chrome browser
- `edge` - Edge browser
- `windows` - Windows desktop
- `macos` - macOS desktop
- `linux` - Linux desktop
- `<android-device-id>` - Android device
- `<ios-device-id>` - iOS device

## Troubleshooting

### Web Issues
- **CORS errors**: Use `flutter run -d chrome --web-browser-flag "--disable-web-security"`
- **Firebase not loading**: Check browser console for errors
- **Storage not working**: Ensure browser allows local storage

### Windows Issues
- **Build fails**: Ensure Visual Studio C++ tools are installed
- **Missing DLLs**: Run from `build/windows/runner/Release/` directory
- **Firebase errors**: Check internet connection

### macOS Issues
- **Pod install fails**: Run `pod repo update`
- **Code signing**: Configure in Xcode
- **Permissions**: Grant necessary entitlements

### Linux Issues
- **GTK errors**: Install `libgtk-3-dev`
- **Build fails**: Ensure clang and cmake are installed
- **Display issues**: Check X11/Wayland configuration

## Deployment Guides

### Web Hosting
Deploy to:
- **Firebase Hosting**: `firebase deploy --only hosting`
- **Netlify**: Drag and drop `build/web/` folder
- **Vercel**: Connect GitHub repo
- **GitHub Pages**: Copy `build/web/` to gh-pages branch

### App Stores
- **Google Play**: Follow Android app publishing guide
- **Apple App Store**: Follow iOS app publishing guide
- **Microsoft Store**: Package Windows app with MSIX
- **Snap Store**: Create snap package for Linux

## Performance Optimization

### Web
- Enable caching in service worker
- Optimize assets (images, fonts)
- Use code splitting

### Desktop
- Use release mode for production
- Optimize asset loading
- Consider native plugins for performance-critical features

### Mobile
- Follow standard Flutter optimization practices
- Use const constructors
- Optimize image sizes

## Next Steps

1. **Test on all platforms** you plan to support
2. **Customize UI** for each platform if needed
3. **Add platform-specific features** using conditional imports
4. **Set up CI/CD** for automated builds
5. **Prepare for distribution** on app stores and web

## Support

For platform-specific issues:
- **Flutter**: https://flutter.dev/docs
- **Firebase**: https://firebase.google.com/docs
- **Platform-specific**: Check the README.md in each platform directory

## Summary

Your ARTIQ app is now truly cross-platform! You can:
- ✅ Build once, run everywhere
- ✅ Use the same codebase for all platforms
- ✅ Firebase authentication works on all platforms
- ✅ Responsive UI adapts to any screen size
- ✅ Offline support where available

Happy coding across all platforms! 🎉
