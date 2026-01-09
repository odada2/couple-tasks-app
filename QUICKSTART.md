# Quick Start Guide - Couple Tasks App

Get your Couple Tasks app up and running in minutes!

## ⚡ Fast Track Setup

### 1. Clone & Install (2 minutes)

```bash
# Clone the repository
git clone https://github.com/odada2/couple-tasks-app.git
cd couple-tasks-app

# Install dependencies
flutter pub get
```

### 2. Firebase Setup (5 minutes)

#### A. Create Firebase Project
1. Go to https://console.firebase.google.com/
2. Click "Add project"
3. Name it "couple-tasks"
4. Click "Create project"

#### B. Configure Firebase for Flutter
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure (this creates firebase_options.dart)
flutterfire configure
```
- Select your Firebase project
- Choose platforms: iOS, Android

#### C. Enable Google Sign-In
1. In Firebase Console → **Authentication**
2. Click "Get Started"
3. Enable **Google** sign-in method
4. Add support email
5. Click "Save"

#### D. Create Firestore Database
1. In Firebase Console → **Firestore Database**
2. Click "Create database"
3. Choose "Start in production mode"
4. Select your region
5. Click "Enable"

#### E. Deploy Security Rules
1. In Firebase Console → **Firestore Database** → **Rules**
2. Copy content from `firestore.rules` file
3. Paste and click "Publish"

#### F. Create Indexes
In Firebase Console → **Firestore Database** → **Indexes** → **Composite**

**Index 1:**
- Collection: `tasks`
- Fields: `coupleId` (Ascending), `createdAt` (Descending)

**Index 2:**
- Collection: `tasks`
- Fields: `status` (Ascending), `dueDate` (Ascending)

### 3. Android Setup (2 minutes)

#### Get SHA-1 Fingerprint
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

#### Add to Firebase
1. Copy the SHA-1 fingerprint
2. In Firebase Console → **Project Settings** → **Your apps**
3. Select Android app
4. Click "Add fingerprint"
5. Paste SHA-1 and save

### 4. Run the App! (1 minute)

```bash
# Connect your device or start emulator
flutter devices

# Run the app
flutter run
```

## 🎉 You're Done!

The app should now be running. Try:
1. Sign in with Google
2. Link with a partner (they need to sign up first)
3. Create your first task
4. Send a loving nudge!

## 🐛 Troubleshooting

### "Firebase not initialized"
- Make sure `firebase_options.dart` exists
- Run `flutterfire configure` again

### "Google Sign-In failed"
- Check SHA-1 fingerprint is added in Firebase Console
- Verify `google-services.json` is in `android/app/`
- Try `flutter clean && flutter run`

### "Permission denied" on Firestore
- Verify security rules are deployed
- Check that you're signed in
- Ensure indexes are created

### "Partner not found"
- Partner must sign up with Google first
- Use exact email address
- Check for typos

## 📱 Test Flow

### As User 1:
1. Sign in with Google
2. Enter User 2's email in couple setup
3. Wait for User 2 to sign up

### As User 2:
1. Sign in with Google
2. Enter User 1's email in couple setup
3. Both should now see shared tasks!

## 📚 Next Steps

- Read **README.md** for full feature list
- Check **FIREBASE_SETUP.md** for detailed Firebase guide
- Review **PROJECT_OVERVIEW.md** for architecture details

## 🆘 Need Help?

- Check the [Issues](https://github.com/odada2/couple-tasks-app/issues) page
- Review Firebase documentation
- Open a new issue on GitHub

---

**Happy collaborating! 💕**
