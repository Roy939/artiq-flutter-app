# Firebase Configuration Checklist

Use this checklist to ensure your Firebase setup is complete.

## ✅ Firebase Console Setup

### 1. Create/Access Firebase Project
- [ ] Go to https://console.firebase.google.com/
- [ ] Create new project OR access existing `artiq-1ebb2` project
- [ ] Note your Project ID: ___________________

### 2. Enable Authentication
- [ ] Navigate to **Authentication** section
- [ ] Click **"Get started"** (if first time)
- [ ] Go to **"Sign-in method"** tab
- [ ] Enable **Email/Password** provider
- [ ] Enable **Google** provider
- [ ] (Optional) Enable **Apple** provider for iOS

### 3. Register Android App
- [ ] Click **"Add app"** → Select **Android** icon
- [ ] Enter package name: `com.example.artiq_flutter`
- [ ] (Optional) Add app nickname: "ARTIQ Android"
- [ ] Click **"Register app"**
- [ ] Download `google-services.json`
- [ ] Save file to: `artiq_flutter/android/app/google-services.json`
- [ ] **IMPORTANT**: Replace the placeholder file with your downloaded file

### 4. Register iOS App
- [ ] Click **"Add app"** → Select **iOS** icon
- [ ] Enter bundle ID: `com.example.artiqFlutter`
- [ ] (Optional) Add app nickname: "ARTIQ iOS"
- [ ] Click **"Register app"**
- [ ] Download `GoogleService-Info.plist`
- [ ] Save file to: `artiq_flutter/ios/Runner/GoogleService-Info.plist`
- [ ] **IMPORTANT**: Replace the placeholder file with your downloaded file

### 5. Update iOS Info.plist
- [ ] Open `GoogleService-Info.plist` you just downloaded
- [ ] Find the value for key `REVERSED_CLIENT_ID`
- [ ] Copy the value (looks like: `com.googleusercontent.apps.123456789-abcdefg`)
- [ ] Open `artiq_flutter/ios/Runner/Info.plist`
- [ ] Find this line: `<string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>`
- [ ] Replace `YOUR-CLIENT-ID` with your actual reversed client ID
- [ ] Save the file

## ✅ Local Project Files

### Android Files
- [ ] `android/app/google-services.json` exists and has real credentials
- [ ] `android/app/build.gradle` has Google services plugin applied
- [ ] `android/build.gradle` has Google services classpath

### iOS Files
- [ ] `ios/Runner/GoogleService-Info.plist` exists and has real credentials
- [ ] `ios/Runner/Info.plist` has correct `REVERSED_CLIENT_ID`
- [ ] `ios/Podfile` exists

## ✅ Verification Steps

### 1. Check File Contents
Run these commands to verify files are not placeholders:

**Android:**
```bash
grep "YOUR_PROJECT_NUMBER" android/app/google-services.json
# Should return NOTHING if file is correct
```

**iOS:**
```bash
grep "YOUR_CLIENT_ID" ios/Runner/GoogleService-Info.plist
# Should return NOTHING if file is correct
```

### 2. Install Dependencies
```bash
flutter pub get
cd ios && pod install && cd ..
```

### 3. Run the App
```bash
flutter run
```

### 4. Test Authentication
- [ ] Open the app
- [ ] Try signing up with email/password
- [ ] Try signing in with email/password
- [ ] Try signing in with Google
- [ ] Verify you can see the home screen after login

## 🔧 Troubleshooting

### "Default FirebaseApp is not initialized"
**Problem**: Firebase configuration files are missing or invalid

**Solution**:
1. Verify `google-services.json` (Android) is in correct location
2. Verify `GoogleService-Info.plist` (iOS) is in correct location
3. Make sure files contain real credentials, not placeholders
4. Run `flutter clean` and `flutter pub get`

### "Google Sign-In failed"
**Problem**: OAuth configuration is incorrect

**Solution for Android**:
1. Get your SHA-1 fingerprint:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
2. Add SHA-1 to Firebase Console → Project Settings → Your Android App
3. Download new `google-services.json` and replace the old one

**Solution for iOS**:
1. Verify `REVERSED_CLIENT_ID` in `Info.plist` matches `GoogleService-Info.plist`
2. Make sure URL scheme is correctly formatted
3. Rebuild the app

### "FirebaseAuthException: [firebase_auth/operation-not-allowed]"
**Problem**: Authentication method not enabled in Firebase Console

**Solution**:
1. Go to Firebase Console → Authentication → Sign-in method
2. Enable the authentication provider you're trying to use
3. Try again

### Build Errors
**Clean and rebuild**:
```bash
flutter clean
rm -rf ios/Pods ios/Podfile.lock
flutter pub get
cd ios && pod install && cd ..
flutter run
```

## 📝 Notes

### Important File Locations
| Platform | File | Location |
|----------|------|----------|
| Android | google-services.json | `android/app/google-services.json` |
| iOS | GoogleService-Info.plist | `ios/Runner/GoogleService-Info.plist` |
| iOS | Info.plist | `ios/Runner/Info.plist` |

### Package Names / Bundle IDs
| Platform | Identifier |
|----------|------------|
| Android | `com.example.artiq_flutter` |
| iOS | `com.example.artiqFlutter` |

### Backend API
- URL: `https://artiq--thompson9395681.replit.app`
- Authentication: Uses Firebase user ID

## ✨ Success Criteria

You've successfully configured Firebase when:
- [ ] App launches without Firebase errors
- [ ] You can create an account with email/password
- [ ] You can sign in with email/password
- [ ] You can sign in with Google
- [ ] You see the Design Gallery after login
- [ ] You can create and save designs
- [ ] Designs sync with the backend when online

---

**Need Help?**
- Firebase Documentation: https://firebase.google.com/docs
- FlutterFire Documentation: https://firebase.flutter.dev/
