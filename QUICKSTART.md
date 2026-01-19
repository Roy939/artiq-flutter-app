# ARTIQ Quick Start Guide

This guide will help you get ARTIQ up and running on your device.

## Step 1: Install Flutter

If you haven't installed Flutter yet, follow these steps:

### macOS
```bash
# Download Flutter SDK
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable

# Add Flutter to PATH (add this to ~/.zshrc or ~/.bash_profile)
export PATH="$PATH:$HOME/development/flutter/bin"

# Verify installation
flutter doctor
```

### Windows
1. Download Flutter SDK from https://flutter.dev/docs/get-started/install/windows
2. Extract the zip file
3. Add Flutter to your PATH
4. Run `flutter doctor` in Command Prompt

### Linux
```bash
# Download Flutter SDK
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable

# Add Flutter to PATH (add this to ~/.bashrc)
export PATH="$PATH:$HOME/development/flutter/bin"

# Verify installation
flutter doctor
```

## Step 2: Set Up Your Development Environment

### For iOS Development (macOS only)
1. Install Xcode from the App Store
2. Install CocoaPods:
   ```bash
   sudo gem install cocoapods
   ```
3. Accept Xcode license:
   ```bash
   sudo xcodebuild -license accept
   ```

### For Android Development
1. Install Android Studio from https://developer.android.com/studio
2. Open Android Studio and install:
   - Android SDK
   - Android SDK Platform
   - Android Virtual Device
3. Accept Android licenses:
   ```bash
   flutter doctor --android-licenses
   ```

## Step 3: Configure Firebase

### Option A: Use Existing Firebase Project (artiq-1ebb2)

If you have access to the existing Firebase project:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Open project `artiq-1ebb2`
3. Download configuration files:
   - **Android**: Download `google-services.json` and place in `android/app/`
   - **iOS**: Download `GoogleService-Info.plist` and place in `ios/Runner/`

### Option B: Create New Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name (e.g., "artiq-your-name")
4. Follow the setup wizard

#### Add Android App
1. Click "Add app" → Android icon
2. Android package name: `com.example.artiq_flutter`
3. Download `google-services.json`
4. Place file in `artiq_flutter/android/app/google-services.json`

#### Add iOS App
1. Click "Add app" → iOS icon
2. iOS bundle ID: `com.example.artiqFlutter`
3. Download `GoogleService-Info.plist`
4. Place file in `artiq_flutter/ios/Runner/GoogleService-Info.plist`
5. Open the file and find `REVERSED_CLIENT_ID` value
6. Update `artiq_flutter/ios/Runner/Info.plist`:
   - Find `<string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>`
   - Replace with your actual `REVERSED_CLIENT_ID`

#### Enable Authentication
1. In Firebase Console, go to **Authentication**
2. Click **"Get started"**
3. Enable **Email/Password** sign-in method
4. Enable **Google** sign-in method

## Step 4: Install Project Dependencies

```bash
cd artiq_flutter

# Get Flutter packages
flutter pub get

# For iOS: Install CocoaPods dependencies
cd ios
pod install
cd ..
```

## Step 5: Run the App

### Connect Your Device

**iOS:**
- Connect your iPhone via USB
- Trust the computer on your device
- Or use iOS Simulator (open Xcode → Xcode menu → Open Developer Tool → Simulator)

**Android:**
- Enable Developer Options on your Android device
- Enable USB Debugging
- Connect via USB
- Or use Android Emulator (open Android Studio → AVD Manager → Create/Start emulator)

### Check Connected Devices
```bash
flutter devices
```

### Run the App
```bash
# Run on the first available device
flutter run

# Or specify a device
flutter run -d <device_id>

# For iOS simulator specifically
flutter run -d "iPhone 14"

# For Android emulator specifically
flutter run -d emulator-5554
```

## Step 6: Test the App

1. **Sign Up**: Create a new account with email and password
2. **Sign In**: Log in with your credentials
3. **Create Design**: Tap the + button to create a new design
4. **Draw**: Use your finger to draw on the canvas
5. **Save**: Tap the save icon to save your design
6. **View Gallery**: See your saved designs in the gallery
7. **Test Offline**: Turn off internet and create another design
8. **Test Sync**: Turn internet back on and pull down to refresh the gallery

## Troubleshooting

### "Flutter not found"
- Make sure Flutter is in your PATH
- Restart your terminal after adding Flutter to PATH
- Run `flutter doctor` to verify installation

### "No devices found"
- For iOS: Make sure Xcode is installed and device is trusted
- For Android: Make sure USB debugging is enabled
- Try `flutter doctor` to see what's missing

### Firebase Authentication Errors
- Verify `google-services.json` is in `android/app/`
- Verify `GoogleService-Info.plist` is in `ios/Runner/`
- Check that authentication methods are enabled in Firebase Console

### Build Errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### Google Sign-In Not Working on iOS
- Verify `REVERSED_CLIENT_ID` is correctly added to `Info.plist`
- Make sure the value matches what's in `GoogleService-Info.plist`

### Android Build Fails
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

## Next Steps

Once the app is running:

1. **Explore the Pen Tool**: Try drawing different shapes and strokes
2. **Test Offline Mode**: Create designs without internet connection
3. **Test Synchronization**: Watch designs sync when you go back online
4. **Customize**: Modify the code to add your own features

## Getting Help

- **Flutter Issues**: https://github.com/flutter/flutter/issues
- **Firebase Issues**: https://firebase.google.com/support
- **ARTIQ Backend**: https://artiq--thompson9395681.replit.app

## Project Files Overview

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry point |
| `lib/src/screens/login_screen.dart` | Login UI |
| `lib/src/screens/design_gallery_screen.dart` | Gallery view |
| `lib/src/screens/create_design_screen.dart` | Design creation |
| `lib/src/widgets/pen_tool_widget.dart` | Drawing canvas |
| `lib/src/services/auth_service.dart` | Firebase authentication |
| `lib/src/services/local_storage_service.dart` | Offline storage |
| `lib/src/services/sync_service.dart` | Data synchronization |
| `lib/src/api/api_service.dart` | Backend API calls |

Happy coding! 🎨
