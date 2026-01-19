# ARTIQ - AI-Powered Design Studio

A professional mobile app for vector drawing with offline-first architecture and AI features.

## Features

- **Professional Vector Pen Tool**: Touch-based drawing with vector data storage
- **Offline-First Architecture**: Create and edit designs without internet connection
- **Firebase Authentication**: Email/Password and Google Sign-In support
- **Design Gallery**: View all your designs with sync status indicators
- **Automatic Sync**: Seamlessly syncs local designs with backend when online
- **Backend Integration**: Connected to Flask API for data persistence

## Prerequisites

Before you begin, ensure you have the following installed:

- Flutter SDK (3.0.0 or higher)
- Dart SDK (included with Flutter)
- Xcode (for iOS development)
- Android Studio (for Android development)
- CocoaPods (for iOS dependencies)

## Firebase Setup

This app requires Firebase configuration. You need to set up your own Firebase project:

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or use existing project `artiq-1ebb2`
3. Enable Authentication with Email/Password and Google Sign-In

### 2. Configure Android

1. In Firebase Console, add an Android app
2. Use package name: `com.example.artiq_flutter`
3. Download `google-services.json`
4. Replace the placeholder file at `android/app/google-services.json`

### 3. Configure iOS

1. In Firebase Console, add an iOS app
2. Use bundle ID: `com.example.artiqFlutter`
3. Download `GoogleService-Info.plist`
4. Replace the placeholder file at `ios/Runner/GoogleService-Info.plist`
5. Update `ios/Runner/Info.plist` with your `REVERSED_CLIENT_ID` from the downloaded plist

## Installation

1. **Clone or extract the project**

2. **Install Flutter dependencies**
   ```bash
   cd artiq_flutter
   flutter pub get
   ```

3. **For iOS: Install CocoaPods dependencies**
   ```bash
   cd ios
   pod install
   cd ..
   ```

## Running the App

### iOS
```bash
flutter run -d ios
```

### Android
```bash
flutter run -d android
```

### Specific Device
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device_id>
```

## Project Structure

```
artiq_flutter/
├── lib/
│   ├── main.dart                    # App entry point
│   └── src/
│       ├── api/
│       │   └── api_service.dart     # Backend API integration
│       ├── auth/                    # Authentication related files
│       ├── data/
│       │   └── designs_provider.dart # State management for designs
│       ├── models/
│       │   ├── design.dart          # Design data model
│       │   └── drawing.dart         # Drawing stroke model
│       ├── screens/
│       │   ├── auth_wrapper.dart    # Authentication state handler
│       │   ├── login_screen.dart    # Login UI
│       │   ├── home_screen.dart     # Main home screen
│       │   ├── design_gallery_screen.dart  # Gallery view
│       │   └── create_design_screen.dart   # Design creation
│       ├── services/
│       │   ├── auth_service.dart           # Firebase auth service
│       │   ├── local_storage_service.dart  # Offline storage
│       │   └── sync_service.dart           # Data synchronization
│       ├── utils/                   # Utility functions
│       └── widgets/
│           ├── drawing_painter.dart # Canvas painter
│           └── pen_tool_widget.dart # Vector drawing widget
├── android/                         # Android configuration
├── ios/                            # iOS configuration
└── pubspec.yaml                    # Dependencies

```

## Backend API

The app connects to: `https://artiq--thompson9395681.replit.app`

API Endpoints:
- `GET /designs/:userId` - Fetch user designs
- `POST /designs` - Create new design
- `PUT /designs/:id` - Update design
- `DELETE /designs/:id` - Delete design

## Troubleshooting

### Firebase Configuration Issues

If you see Firebase errors:
1. Ensure `google-services.json` (Android) has valid credentials
2. Ensure `GoogleService-Info.plist` (iOS) has valid credentials
3. Verify bundle ID and package name match Firebase console

### Build Errors

**Android:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

**iOS:**
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

### Google Sign-In Issues

- **iOS**: Make sure `REVERSED_CLIENT_ID` is correctly added to `Info.plist`
- **Android**: Ensure SHA-1 fingerprint is added in Firebase Console

## Next Steps

1. Replace placeholder Firebase configuration files with your actual credentials
2. Test authentication with Email/Password
3. Test Google Sign-In
4. Create a design using the pen tool
5. Test offline functionality by turning off internet
6. Test sync by turning internet back on and pulling to refresh

## Support

For issues or questions, refer to:
- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
