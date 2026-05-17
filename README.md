# Solar Install Pro

Solar Install Pro is a Flutter-based solar estimation app that helps users calculate electricity usage, estimate monthly bills, recommend a suitable solar system, and measure return on investment. It is designed as a practical decision-support tool for homeowners, shops, offices, farms, and industrial users.

## Project Overview

The app removes the need for manual solar calculations by guiding the user through a simple flow:

1. Choose a property type.
2. Select appliances and usage hours.
3. Estimate the electricity bill.
4. Recommend a solar system type.
5. Calculate solar setup cost and ROI.
6. Save the result to cloud history for future comparison.

## Problem Statement

Many people want to install solar panels but do not know:

- how much electricity their appliances actually consume,
- what their current monthly bill means in solar terms,
- what size solar system they need,
- how much it will cost,
- and when the system will recover the initial investment.

This project solves that by turning complex solar planning into a guided mobile experience.

## Proposed Solution

The app acts like a virtual solar consultant.

- It estimates load from appliance selection and usage time.
- It generates a monthly and yearly electricity bill estimate.
- It recommends On-Grid, Off-Grid, or Hybrid systems based on usage.
- It estimates panel count, inverter size, battery count, and total cost.
- It calculates monthly savings and ROI.
- It stores previous calculations in Firestore.

## System Architecture

The app is built in Flutter and uses Firebase services for authentication and cloud storage.

- **Frontend:** Flutter / Dart
- **Authentication:** Firebase Authentication
- **Cloud Storage:** Cloud Firestore
- **Local Storage:** Shared Preferences
- **Rate Data Loading:** HTTP + bundled JSON asset
- **UI Pattern:** Material Design 3 with a global light/dark theme toggle

## Main App Flow

### 1. Startup
The app starts from [lib/main.dart](lib/main.dart), initializes Firebase, and opens the splash screen.

### 2. Authentication
Users sign up or log in with email and password.

- Signup stores the display name and email.
- Login verifies the user with Firebase Auth.
- Sign out clears the session and returns the user to the login screen.

### 3. Home Screen
The home screen is the dashboard.

- It shows property categories such as single-story house, double-story house, office, shop, agriculture, and industrial.
- It includes a dark/light theme toggle.
- It provides quick access to history, about, contact, and sign out.

### 4. Appliance Selection
After choosing a property type, the app loads a preset appliance list from [lib/models/appliance_model.dart](lib/models/appliance_model.dart).

- Users select appliances.
- They can adjust quantity.
- They can add custom appliances if needed.

### 5. Usage Time Entry
Users set daily usage hours for each appliance and may also adjust usage days.

- The app calculates total energy in kWh.
- It converts appliance wattage, quantity, and time into a combined load profile.

### 6. Bill Estimation
The bill screen applies electricity company tariffs, surcharges, taxes, and fees.

- It shows the estimated total bill.
- It shows yearly cost projections.
- It prepares the user for solar comparison.

### 7. Solar Recommendation
Based on monthly units, the app recommends one of three system types:

- **On-Grid** for larger stable loads
- **Hybrid** for backup plus grid support
- **Off-Grid** for isolated or backup-focused setups

### 8. System Details and Sizing
The app estimates:

- recommended solar panel count,
- inverter size,
- battery requirement,
- system cost,
- and component breakdown.

### 9. ROI Analysis
The ROI screen compares the user’s bill without solar to the projected bill with solar.

- It estimates monthly savings.
- It estimates yearly savings.
- It calculates payback time in months and years.

### 10. Summary and History
The summary screen saves the final analysis to Firestore.

- Saved results can be viewed later in the History screen.
- Users can delete one record or clear all records.

## Key Screens

- Splash Screen
- Login Screen
- Signup Screen
- Main Layout
- Home Screen
- Appliances Selection Screen
- Appliance Usage Screen
- Bill Generation Screen
- Generated Bill Screen
- System Recommendation Screen
- System Details Screen
- Solar ROI Screen
- Solar Summary Screen
- History Screen
- About Screen
- Contact Screen

## Core Data Model

The main appliance model stores:

- appliance name,
- wattage,
- icon,
- quantity,
- hours per day,
- days per month,
- custom wattage if the user adds their own appliance.

## What Makes This Project Strong

- It solves a real financial problem.
- It combines UI, calculations, authentication, and cloud storage.
- It is practical for both domestic and commercial users.
- It produces explainable outputs that can be shown in a presentation.
- It has a clean flow from user input to final savings result.

## Technologies Used

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Shared Preferences
- HTTP package
- Material 3 UI

## Presentation Script

### Short Introduction
“Good morning/afternoon. My project is Solar Install Pro, a Flutter application that helps users estimate electricity usage, calculate monthly bills, recommend a solar system, and analyze return on investment.”

### Problem
“Many users want to install solar panels, but they do not know their real load, system size, cost, or payback time. This makes solar adoption confusing and expensive.”

### Solution
“This app simplifies the process. The user selects a property type, chooses appliances, enters usage hours, and the app automatically calculates energy consumption, bill estimates, solar recommendations, and ROI.”

### Technical Highlights
“The frontend is built in Flutter, authentication is handled by Firebase Auth, history is stored in Firestore, and the app supports dark mode with a global theme toggle.”

### Final Outcome
“At the end, the user gets a complete solar decision report, including estimated cost, savings, payback time, and saved history for later comparison.”

## Build a Secure Android APK

1. Generate a release keystore in the project root:

	```powershell
	keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
	```

2. Create the signing config file:

	- Copy [android/key.properties.example](android/key.properties.example) to [android/key.properties](android/key.properties)
	- Fill in the real values for `storePassword`, `keyPassword`, `keyAlias`, and `storeFile`

3. Build the release APK:

	```powershell
	flutter pub get
	flutter build apk --release
	```

4. Install the APK on an Android phone:

	- Output file: [build/app/outputs/flutter-apk/app-release.apk](build/app/outputs/flutter-apk/app-release.apk)
	- Transfer it to the phone and install it
	- Enable **Install unknown apps** if your file manager or browser asks for permission

5. Optional smaller APKs:

	```powershell
	flutter build apk --release --split-per-abi
	```
