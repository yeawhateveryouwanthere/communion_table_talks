# Communion Table Talks — MacBook Setup Guide

**For picking up development on your MacBook Pro**

---

## What You Need Installed

Before you start, make sure these are on your Mac. Open **Terminal** (Cmd + Space, type "Terminal") and run each check.

### 1. Git (probably already installed)

```bash
git --version
```

If not installed, macOS will prompt you to install Xcode Command Line Tools. Say yes.

### 2. Flutter SDK

```bash
flutter --version
```

If not installed, go to: **https://docs.flutter.dev/get-started/install/macos**

Follow the macOS instructions. The key steps are:

- Download the Flutter SDK
- Extract it (e.g., to `~/development/flutter`)
- Add Flutter to your PATH by adding this line to `~/.zshrc`:

```bash
export PATH="$HOME/development/flutter/bin:$PATH"
```

Then run:

```bash
source ~/.zshrc
flutter doctor
```

`flutter doctor` will tell you what else you need (Xcode, Android Studio, Chrome, etc.).

### 3. Xcode (for iOS development)

Install from the Mac App Store, then run:

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

### 4. Android Studio (for Android development)

Download from: **https://developer.android.com/studio**

After installing, open it and go through the setup wizard (it will install the Android SDK). Then accept licenses:

```bash
flutter doctor --android-licenses
```

### 5. FlutterFire CLI (for Firebase)

```bash
dart pub global activate flutterfire_cli
```

---

## Clone the Project

### Step 1: Push everything from your Windows PC first

**On your Windows machine**, open a terminal in the project folder (`C:\Users\junkf\Dev\communion_table_talks`) and run:

```bash
git add -A
git commit -m "Add admin tools, presentation JSON files, and upload pages"
git push origin main
```

This pushes the admin tool, all the JSON presentation files, and everything else to GitHub.

### Step 2: Clone on your Mac

Open Terminal on your MacBook and run:

```bash
cd ~/Dev
git clone https://github.com/yeawhateveryouwanthere/communion_table_talks.git
cd communion_table_talks
```

*(If you prefer a different directory than `~/Dev`, just change the `cd` line.)*

---

## Set Up the Project

### Step 1: Get Flutter dependencies

```bash
flutter pub get
```

### Step 2: Verify Firebase configuration

The Firebase config files are already in the project:

- `lib/firebase_options.dart` — auto-generated config
- `android/app/google-services.json` — Android config
- `ios/Runner/GoogleService-Info.plist` — iOS config

These should come through with the git clone. Verify they exist:

```bash
ls lib/firebase_options.dart
ls android/app/google-services.json
ls ios/Runner/GoogleService-Info.plist
```

If any are missing (they might be in `.gitignore`), you can regenerate them:

```bash
flutterfire configure --project=communion-table-talks
```

### Step 3: Run the app

**On Chrome (easiest first test):**

```bash
flutter run -d chrome
```

**On iOS Simulator:**

```bash
open -a Simulator
flutter run
```

**On a physical iPhone (connected via USB):**

```bash
flutter run
```

Flutter will detect the device automatically.

---

## Working with the Admin Tool

The admin HTML pages don't need Flutter at all — they're standalone web pages that connect directly to Firestore.

To use them on your Mac, just open them in any browser:

```bash
open admin/presentation_admin.html
```

This is where you can browse, edit, and manage all 85 presentations in Firestore.

The upload page for your 22 original presentations is at:

```bash
open admin/upload_michael.html
```

*(Only use this if you haven't already uploaded them from your Windows machine.)*

---

## Editing Presentations on the Train

You have two good options:

### Option A: Use the Admin Tool (no code needed)

Just open `admin/presentation_admin.html` in Safari or Chrome on your Mac. It connects to Firestore over the internet, so you can edit any presentation from anywhere. This is the fastest way to review and tweak the 22 presentations you want to edit.

### Option B: Edit the JSON files locally

The presentation data lives in JSON files under `admin/`:

- `presentations_michael.json` — your 22 original presentations
- `presentations_brief.json` — 20 brief presentations
- `presentations_medium_1.json` and `presentations_medium_2.json` — 20 medium
- `presentations_substantive_1.json` and `presentations_substantive_2.json` — 20 substantive

You can edit these with any text editor (VS Code, Sublime, etc.) and re-upload using the HTML upload pages.

---

## Syncing Changes Between Machines

After making changes on your Mac:

```bash
git add -A
git commit -m "Description of your changes"
git push origin main
```

Then on your Windows machine later:

```bash
git pull origin main
```

And vice versa — always push before switching machines, pull when you arrive.

---

## Quick Reference

| Task | Command |
|------|---------|
| Run on Chrome | `flutter run -d chrome` |
| Run on iOS Simulator | `open -a Simulator && flutter run` |
| Run on Android emulator | `flutter run -d emulator-5554` |
| Get dependencies | `flutter pub get` |
| Check setup | `flutter doctor` |
| Open admin tool | `open admin/presentation_admin.html` |
| Push to GitHub | `git add -A && git commit -m "msg" && git push` |
| Pull from GitHub | `git pull origin main` |

---

## Project Structure (Key Files)

```
communion_table_talks/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── firebase_options.dart        # Firebase config
│   ├── models/
│   │   └── presentation.dart        # Data model
│   └── screens/
│       ├── my_presentations_screen.dart
│       ├── select_date_screen.dart
│       ├── browse_presentations_screen.dart
│       └── presentation_detail_screen.dart
├── admin/
│   ├── presentation_admin.html      # Full admin tool
│   ├── upload_michael.html          # Upload your 22 presentations
│   ├── upload_presentations.html    # Upload the 60 AI-written presentations
│   ├── presentations_michael.json   # Your 22 presentations (JSON)
│   ├── presentations_brief.json     # 20 brief presentations
│   ├── presentations_medium_1.json  # 10 medium presentations
│   ├── presentations_medium_2.json  # 10 medium presentations
│   ├── presentations_substantive_1.json  # 10 substantive presentations
│   └── presentations_substantive_2.json  # 10 substantive presentations
├── android/                         # Android platform files
├── ios/                             # iOS platform files
└── web/                             # Web platform files
```

---

## Troubleshooting

**"CocoaPods not installed"** — Run: `sudo gem install cocoapods`

**"Xcode not configured"** — Run: `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`

**iOS build fails with signing error** — Open `ios/Runner.xcworkspace` in Xcode, go to Signing & Capabilities, and select your Apple Developer team.

**"Firebase app not initialized"** — Make sure `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) exist in the right locations. Re-run `flutterfire configure` if needed.

**flutter doctor shows issues** — Follow each suggestion it gives. It's very specific about what's missing.
