# EcoWaste Flutter App 🌱

A beautiful Android app for reporting waste, earning eco points, and tracking your environmental impact.

## Screens
| Screen | Description |
|---|---|
| Splash | Auto-login check, animated logo |
| Login | JWT-based login |
| Register | Create a new citizen account |
| Home (Dashboard) | Stats, eco points, quick actions |
| Report Waste | Take photo + submit waste report |
| My Reports | List all your reports with status |
| Leaderboard | Top 10 eco warriors |
| Profile | Your info, stats, and logout |

---

## Setup Instructions

### 1. Install Flutter
Download Flutter SDK from https://docs.flutter.dev/get-started/install/windows

After downloading:
1. Extract to `C:\src\flutter`
2. Add `C:\src\flutter\bin` to your Windows PATH environment variable
3. Restart your terminal
4. Run `flutter doctor` to verify

### 2. Install Android Studio
Download from https://developer.android.com/studio
- Install "Android SDK" during setup
- Create an Android Virtual Device (AVD) for testing

### 3. Install app dependencies
Open this folder in a terminal and run:
```bash
flutter pub get
```

### 4. Run the app
```bash
# On emulator or connected Android device
flutter run

# Build release APK
flutter build apk --release
```

---

## Project Structure
```
lib/
├── main.dart                  # Entry + splash screen
├── core/
│   ├── constants.dart         # API URLs
│   └── theme.dart             # Dark green design system
├── services/
│   ├── auth_service.dart      # JWT token storage + login/register
│   └── api_service.dart       # All API endpoint calls
└── screens/
    ├── login_screen.dart
    ├── register_screen.dart
    ├── home_screen.dart       # Dashboard + bottom nav
    ├── report_screen.dart     # Submit waste report
    ├── my_reports_screen.dart
    ├── leaderboard_screen.dart
    └── profile_screen.dart
```

## API
The app connects to: `https://eco-waste.vercel.app/api/v1/`
