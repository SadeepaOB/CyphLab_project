# Expense Tracker - Flutter Mobile App

A clean, beginner-friendly **Expense Tracker** mobile application built with Flutter and Firebase Cloud Firestore for a job application task.

The project is intentionally designed with simplicity and readability in mind:
- **No over-engineering** or heavy architecture bloat.
- **Straightforward state management** using native `setState` and reactive Flutter widgets (`StreamBuilder`, `Form`).
- **Clean separation of concerns** into `models/`, `screens/`, `widgets/`, and `services/`.
- **Zero-barrier evaluation**: Includes automatic fallback to interactive demo data so the app can be run and tested immediately out-of-the-box, even before connecting a live Firebase project!

---

## 📱 Features

### 🌟 Core Requirements
1. **Add New Expense**: Quickly log an expense with title, amount, category, date, and an optional note/description.
2. **Edit Existing Expense**: Tap any transaction to edit its details and save changes in real time.
3. **Delete Expense**: Delete unwanted expenses with a safety confirmation dialog.
4. **Firebase Cloud Firestore Storage**: All expenses are stored in a Firestore collection (`expenses`) with timestamps.
5. **Monthly Expense Total**: A prominent header card calculating total expenses and transaction count for the current or selected month, complete with previous/next month navigation buttons.
6. **Expense History List**: Chronological transaction list displayed with the most recent expenses first.
7. **Filters & Search**:
   - Filter by **Category** (Food & Dining, Shopping, Transportation, Bills & Utilities, Entertainment, Health & Medical, Education, Other).
   - Filter by **Date Range** with an intuitive date range picker.
   - **Search by Title & Notes** via the AppBar search bar.
8. **Form Validation**:
   - Title is required.
   - Amount must be a valid positive number (`> 0`).
   - Category is required.
   - Date is required.
9. **Three Robust UI States**:
   - ⏳ **Loading State**: Clean `CircularProgressIndicator` while data is being fetched.
   - 📭 **Empty State**: Friendly illustration and message with an "Add Expense" call-to-action when no records exist.
   - ⚠️ **Error State**: User-friendly error message with a "Retry" button to easily recover from network hiccups.

### ✨ Bonus / Nice-to-Have Features
- **Visual Spending Breakdown**: Toggleable category breakdown showing total amounts and percentage progress bars.
- **Dark Mode Toggle**: One-tap toggle between Light and Dark Material 3 themes in the top AppBar.
- **Pull-to-Refresh**: Native pull-to-refresh on the expense list.
- **Offline / Zero-Config Demo Mode**: Allows immediate testing by any reviewer without needing to register a Firebase project beforehand.

---

## 📁 Project Structure

The project follows a standard, beginner-friendly directory structure that is easy to navigate and explain during an interview:

```text
lib/
├── main.dart                          # App entry point, theme configuration (Light & Dark)
├── models/
│   └── expense_model.dart             # Expense data model & Firestore serialization (toMap / fromFirestore)
├── screens/
│   ├── home_screen.dart               # Main dashboard with monthly summary, list, filters, & search
│   └── add_edit_expense_screen.dart   # Form for adding and updating expenses with validation
├── widgets/
│   ├── category_helper.dart           # Helper for category icons and color coding
│   ├── category_breakdown.dart        # Visual spending progress breakdown by category
│   ├── expense_summary_card.dart      # Monthly total banner with month navigation controls
│   └── expense_tile.dart              # Individual expense list tile with edit and delete actions
└── services/
    └── firebase_service.dart          # Firestore CRUD operations & real-time streams
```

---

## 🛠️ Technologies & Packages Used

| Package | Version | Purpose |
| :--- | :--- | :--- |
| **Flutter SDK** | `^3.10.7` | Cross-platform UI toolkit |
| **firebase_core** | `^4.15.0` | Firebase initialization |
| **cloud_firestore** | `^6.10.0` | Cloud Firestore database for real-time document storage |
| **intl** | `^0.20.3` | Date formatting (`MMM dd, yyyy`) and currency formatting (`$XX.XX`) |

---

## 🚀 Getting Started & How to Run

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed (version 3.10 or higher).
- An Android device/emulator, iOS simulator, or Chrome browser.

### 1. Clone the Repository
```bash
git clone https://github.com/SadeepaOB/CyphLab_project.git
cd CyphLab_project
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run the App
To run the app immediately in demo mode:
```bash
flutter run
```
> **Tip for Evaluators:** The app includes a built-in interactive demo mode with preloaded sample expenses. You can add, edit, filter, and delete expenses immediately without setting up Firebase credentials!

---

## ☁️ Connecting to your own Firebase Project (Optional)

If you would like to connect the app to a live Firebase Cloud Firestore database:

1. Create a project at the [Firebase Console](https://console.firebase.google.com/).
2. Enable **Cloud Firestore** in test mode (or configure standard security rules).
3. Register your app (Android/iOS/Web) or run FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
4. For Android: Place your downloaded `google-services.json` in `android/app/`.
5. For iOS: Place `GoogleService-Info.plist` in `ios/Runner/`.
6. Run the app:
   ```bash
   flutter run
   ```

---

## 🤖 Note on AI Tools Used

During the development of this project, AI assistance (**Antigravity IDE with Gemini**) was used as a pair programmer:
- **Scaffolding & Architecture**: Fast generation of standard boilerplate, directory separation, and pubspec dependencies.
- **Form Validation & Date Logic**: Writing clean date-range comparison and form validation rules.
- **Zero-Barrier Reviewer Experience**: Generating the in-memory fallback mechanism in `FirebaseService` so hiring managers can run and test the app without setting up Firebase configuration files first.
- **Documentation**: Structuring this comprehensive README to ensure clarity for job application evaluation and code explanation.

---

## 🧪 Testing & Code Quality

Run tests and static analysis:
```bash
# Analyze code for lint rules and potential issues
flutter analyze

# Run widget tests
flutter test
```

---

## 📄 License
This project is open-source and available under the [MIT License](LICENSE).