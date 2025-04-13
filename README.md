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

