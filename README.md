# Flutter Task Manager App

This is a Flutter Task Manager application built for the Flutter Development Internship assignment.

## Features
- **User Authentication:** Firebase Auth (Sign up, Login, Logout)
- **Task Management:** Cloud Firestore (Add, Edit, Delete, Mark as Completed)
- **REST API Integration:** Fetches and displays a random motivational quote from `api.quotable.io/random`.
- **UI & State Management:** Clean UI, proper form validation, loading states, and error handling.

## Requirements
- Flutter SDK
- Android Studio / VS Code
- A Firebase Project

## Setup Steps
1. Clone the repository.
2. Run `flutter pub get` to install the dependencies.
3. Setup Firebase for this project:
   - Create a Firebase project in the [Firebase Console](https://console.firebase.google.com/).
   - Enable **Authentication** (Email/Password).
   - Enable **Firestore Database** (start in test mode for development).
   - Add an Android App to your Firebase project and download `google-services.json`. Place it in the `android/app/` directory.
   - Add an iOS App (if needed) and place the `GoogleService-Info.plist` in `ios/Runner/`.
4. Run the app:
   ```bash
   flutter run
   ```

## Folder Structure
```
lib/
├── screens/
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── home_screen.dart
│   └── add_edit_task_screen.dart
├── services/
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── api_service.dart
├── models/
│   └── task_model.dart
├── widgets/
└── main.dart
```

## Demo Video
*(Insert Link to Demo Video Here)*

## APK File
*(Insert Link to APK File or mention it is in the releases/build folder)*
