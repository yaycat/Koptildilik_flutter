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
<pre> ```text lib/ ├── screens/ # Application screens │ ├── about/ # About screen │ │ └── about_screen.dart │ ├── auth/ # Authentication-related screens │ │ ├── auth_screen.dart │ │ ├── login_screen.dart │ │ ├── login_with_pin_screen.dart │ │ └── register_screen.dart │ ├── common/ # Common reusable screens │ │ ├── first_screen.dart │ │ ├── second_screen.dart │ │ └── third_screen.dart │ ├── home/ # Home and initial choice screens │ │ ├── choose_screen.dart │ │ └── main_screen.dart │ ├── pin/ # PIN creation screen │ │ └── create_pin_screen.dart │ ├── profile/ # User profile screen │ │ └── profile_screen.dart │ ├── progress/ # User progress tracking │ │ └── progress_screen.dart │ ├── search/ # Word search screen │ │ └── search_screen.dart │ ├── settings/ # Settings screen │ │ └── settings_screen.dart │ └── words/ # Dictionary or word list screen │ └── word_screen.dart ├── services/ # Business logic and data handling │ ├── user.dart # User model or logic │ └── user_storage.dart # User data storage handling ├── app.dart # App initialization and configuration ├── global.dart # Global constants and utilities └── main.dart # Main entry point of the app pubspec.yaml # Project dependencies and metadata ``` </pre>
