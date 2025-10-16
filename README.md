# Survey Plans (Flutter + Firebase) — Windows & Android

Follow these steps to generate platform folders and build for **Windows** and **Android**.

## 1) Create platform scaffolding
```
flutter create .
```
If prompted, keep existing `pubspec.yaml`.

## 2) Packages
```
flutter pub get
```

## 3) Android setup
In `android/build.gradle` add:
```
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.2'
    }
}
```
In `android/app/build.gradle` add at bottom:
```
apply plugin: 'com.google.gms.google-services'
```

## 4) Run
```
flutter run -d windows   # Desktop
flutter run -d android   # Android
```

## 5) Build
```
flutter build windows
flutter build apk
```
