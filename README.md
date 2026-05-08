# 🚀 TaskFlow: Premium Task Management App

TaskFlow is a modern, feature-rich task management application built with **Flutter** and **Firebase**. This project was developed as part of a high-performance Flutter Development Internship assignment, focusing on clean architecture, premium UI/UX, and robust backend integration.

## ✨ Key Features

- **🔐 Secure Authentication:** Seamless Sign-up and Login flow powered by Firebase Auth.
- **☁️ Real-time Synchronization:** CRUD operations (Create, Read, Update, Delete) synced instantly with Cloud Firestore.
- **💡 Motivational Quotes:** Integrated with a REST API to provide daily inspiration directly in your task dashboard.
- **🎨 Premium UI/UX:** Built with a custom design system using Google Fonts (Inter), custom circular progress indicators, and smooth transitions.
- **✅ Status Tracking:** Easily manage task lifecycle with "Pending" and "Completed" states.
- **📅 Smart Date Selection:** Integrated date picker for organized task scheduling.

## 🛠️ Tech Stack

- **Framework:** Flutter
- **Database:** Cloud Firestore
- **Auth:** Firebase Authentication
- **API:** [Quotable REST API](https://api.quotable.io/random)
- **State Management:** Stream-based reactive UI

## 📂 Project Structure

The project follows a clean, modular architecture:

```text
lib/
├── models/         # Data structures and serialization
├── screens/        # UI Views and screen-specific logic
├── services/       # External integrations (Auth, Firestore, API)
└── main.dart       # Application entry point & Global Theme
```

## 🚀 Quick Start

1. **Clone & Install:**
   ```bash
   git clone <your-repo-url>
   flutter pub get
   ```

2. **Firebase Setup:**
   - Configure `google-services.json` in `android/app/`.
   - Enable **Firestore** and **Auth** in your Firebase Console.

3. **Launch:**
   ```bash
   flutter run
   ```

---

## 📽️ Demo Video
[Click here to watch the demo](*(Insert your link here)*)

## 📦 APK Download
[Download TaskFlow APK](https://github.com/Prashantj44/TaskFLow/releases/download/v1.0.0/app-release.apk)

---
*Developed with ❤️ as an Internship Project*
