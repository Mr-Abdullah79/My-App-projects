# My-App-projects
# semester_project_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Build a Secure Android APK

1. Generate a release keystore (run in project root):

	```powershell
	keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
	```

2. Create signing config file:

	- Copy [android/key.properties.example](android/key.properties.example) to [android/key.properties](android/key.properties)
	- Fill real values for `storePassword`, `keyPassword`, `keyAlias`, and `storeFile`

3. Build release APK:

	```powershell
	flutter pub get
	flutter build apk --release
	```

4. Install APK on Android phone:

	- Output file: [build/app/outputs/flutter-apk/app-release.apk](build/app/outputs/flutter-apk/app-release.apk)
	- Transfer to mobile and install (enable **Install unknown apps** for your file manager/browser if required)

5. Optional (smaller APKs):

	```powershell
	flutter build apk --release --split-per-abi
	```
