_# ARTIQ Flutter App Setup Guide

This guide will walk you through the steps to set up and run the ARTIQ Flutter application on your local machine.

## 1. Prerequisites

- **Install Flutter:** Make sure you have the Flutter SDK installed on your system. If you don't, follow the official installation guide: [https://flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
- **Set up an editor:** Configure your editor with the Flutter and Dart plugins.
- **Firebase CLI:** Install the Firebase CLI: `npm install -g firebase-tools`

## 2. Firebase Project Setup

The app uses Firebase for authentication. You will need to create your own Firebase project to run the app.

### 2.1. Create a Firebase Project

1.  Go to the [Firebase console](https://console.firebase.google.com/).
2.  Click **"Add project"** and follow the on-screen instructions to create a new project. The project ID `artiq-1ebb2` is already in use, so you will need to choose a unique one.

### 2.2. Configure Firebase for your App

You need to register your iOS and Android apps with the Firebase project.

**For iOS:**

1.  In your Firebase project, go to **Project Overview** and click the **iOS+** icon.
2.  Enter your **iOS bundle ID**. This must match the `PRODUCT_BUNDLE_IDENTIFIER` in your Xcode project (e.g., `com.example.artiqFlutter`).
3.  Click **"Register app"**.
4.  Download the `GoogleService-Info.plist` file.
5.  Place the `GoogleService-Info.plist` file in the `ios/Runner/` directory of your Flutter project.
6.  Follow the remaining setup instructions in the Firebase console.

**For Android:**

1.  In your Firebase project, go to **Project Overview** and click the **Android** icon.
2.  Enter your **Android package name**. This must match the `applicationId` in your `android/app/build.gradle` file (e.g., `com.example.artiq_flutter`).
3.  Click **"Register app"**.
4.  Download the `google-services.json` file.
5.  Place the `google-services.json` file in the `android/app/` directory of your Flutter project.
6.  Follow the remaining setup instructions in the Firebase console. You will need to add the Google Services Gradle plugin to your project's `build.gradle` files.

### 2.3. Enable Authentication Methods

1.  In the Firebase console, go to the **Authentication** section.
2.  Click the **"Sign-in method"** tab.
3.  Enable the **"Email/Password"** and **"Google"** sign-in providers.
4.  For Google Sign-In on iOS, you will need to add a `CFBundleURLTypes` entry to your `ios/Runner/Info.plist` file. You can find the `REVERSED_CLIENT_ID` value in your `GoogleService-Info.plist` file.

## 3. Running the App

Once you have completed the Firebase setup, you can run the app:

```bash
# Navigate to the project directory
cd artiq_flutter

# Install dependencies
flutter pub get

# Run the app
flutter run
```
_
