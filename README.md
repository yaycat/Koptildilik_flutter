# Koptildilik

This Flutter application demonstrates **data persistence**, **JSON serialization**, and **local file-based networking**. It was developed as part of Assignment 4 for the _Cross-platform Mobile Development_ course.

---

## 📱 Features

### ✅ 1. Shared Preferences
- Users can enter their **login**, **email**, and **password** via a registration form.
- The app saves this data locally using the `shared_preferences` plugin.
- On app launch, the saved login is shown with a welcome message.

### ✅ 2. JSON Serialization
- The app defines a `User` class with `id`, `name`, and `email`.
- User data is serialized to JSON format and stored locally in a file.
- When needed, the app reads and deserializes this JSON to restore the list of users.

### ✅ 3. Local Networking Simulation
- Instead of fetching users from an online API, the app simulates networking by reading from a local JSON file (`users.json`).
- This file is copied from `assets` to the app's documents directory on the first run.
- New users registered in the app are appended to this local file.

---

## 📂 Project Structure
lib/
├── screens/                
│   ├── about/              
│   │   └── about_screen.dart
│   ├── auth/              
│   │   ├── auth_screen.dart
│   │   ├── login_screen.dart
│   │   ├── login_with_pin_screen.dart
│   │   └── register_screen.dart
│   ├── common/             
│   │   ├── first_screen.dart
│   │   ├── second_screen.dart
│   │   └── third_screen.dart
│   ├── home/               
│   │   ├── choose_screen.dart
│   │   └── main_screen.dart
│   ├── pin/                
│   │   └── create_pin_screen.dart
│   ├── profile/           
│   │   └── profile_screen.dart
│   ├── progress/          
│   │   └── progress_screen.dart
│   ├── search/             
│   │   └── search_screen.dart
│   ├── settings/           
│   │   └── settings_screen.dart
│   └── words/              
│       └── word_screen.dart
│
├── services/               
│   ├── user.dart
│   └── user_storage.dart
│
├── app.dart                
├── global.dart             
└── main.dart               

pubspec.yaml                

