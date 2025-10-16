# Survey Plans — Google Sign-In Only

This package contains the updated files to make your Flutter app use **only Google Sign-In** via Firebase Auth.

## How to use
1. Create (or open) your Flutter project folder.
2. Extract these files into it, **overwriting** existing files.
3. Confirm `google-services.json` exists at `android/app/google-services.json`.
4. Confirm `lib/firebase_options.dart` matches your Firebase project.
5. Add your device/app **SHA-1 and SHA-256** in Firebase Console > Project Settings > Android app.
6. Run:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

If you already have more screens, wire your initial post-login screen in `lib/main.dart` by replacing `HomeScreen()`.
