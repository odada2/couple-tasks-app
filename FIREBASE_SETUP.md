# Firebase Setup Guide for Couple Tasks

This guide will walk you through setting up Firebase for the Couple Tasks app.

## Prerequisites

- A Google account
- Flutter SDK installed
- FlutterFire CLI installed

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: `couple-tasks` (or your preferred name)
4. Enable/disable Google Analytics (optional)
5. Click "Create project"

## Step 2: Install FlutterFire CLI

```bash
# Install FlutterFire CLI globally
dart pub global activate flutterfire_cli

# Verify installation
flutterfire --version
```

## Step 3: Configure Firebase for Flutter

```bash
# Navigate to your project directory
cd couple_tasks

# Run FlutterFire configure
flutterfire configure

# Select your Firebase project
# Choose platforms: iOS, Android, Web (optional)
# This will create firebase_options.dart automatically
```

## Step 4: Enable Authentication

### Google Sign-In

1. In Firebase Console, go to **Authentication**
2. Click **Get Started**
3. Go to **Sign-in method** tab
4. Click **Google**
5. Toggle **Enable**
6. Select support email
7. Click **Save**

### Android Configuration

1. Get your SHA-1 fingerprint:
```bash
# Debug key
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Release key (for production)
keytool -list -v -keystore /path/to/your/keystore.jks -alias your-key-alias
```

2. In Firebase Console:
   - Go to **Project Settings** > **Your apps**
   - Select your Android app
   - Click **Add fingerprint**
   - Paste SHA-1 fingerprint
   - Click **Save**

### iOS Configuration

1. In Firebase Console:
   - Go to **Project Settings** > **Your apps**
   - Download `GoogleService-Info.plist`
   - Add to `ios/Runner/` in Xcode

2. Update `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
    </array>
  </dict>
</array>
```

## Step 5: Set Up Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click **Create database**
3. Select **Start in production mode**
4. Choose location (select closest to your users)
5. Click **Enable**

### Deploy Security Rules

1. Copy the contents of `firestore.rules` file
2. In Firebase Console:
   - Go to **Firestore Database** > **Rules**
   - Paste the rules
   - Click **Publish**

Or use Firebase CLI:
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize Firebase in project
firebase init firestore

# Deploy rules
firebase deploy --only firestore:rules
```

## Step 6: Create Firestore Indexes

### Required Indexes

1. **Tasks by Couple and Creation Date**
   - Collection: `tasks`
   - Fields: 
     - `coupleId` (Ascending)
     - `createdAt` (Descending)

2. **Tasks by Status and Due Date**
   - Collection: `tasks`
   - Fields:
     - `status` (Ascending)
     - `dueDate` (Ascending)

### Create Indexes via Console

1. Go to **Firestore Database** > **Indexes**
2. Click **Create Index**
3. Enter collection ID: `tasks`
4. Add fields as specified above
5. Click **Create**

### Create Indexes via CLI

Create `firestore.indexes.json`:
```json
{
  "indexes": [
    {
      "collectionGroup": "tasks",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "coupleId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "tasks",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "status",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "dueDate",
          "order": "ASCENDING"
        }
      ]
    }
  ]
}
```

Deploy:
```bash
firebase deploy --only firestore:indexes
```

## Step 7: Enable Firebase Cloud Messaging (Optional)

For push notifications:

1. In Firebase Console, go to **Cloud Messaging**
2. Note your **Server Key** and **Sender ID**
3. For Android:
   - Add `google-services.json` to `android/app/`
4. For iOS:
   - Enable Push Notifications in Xcode
   - Upload APNs certificate to Firebase

## Step 8: Test Your Setup

```bash
# Run the app
flutter run

# Try signing in with Google
# Create a couple link
# Create and manage tasks
```

## Troubleshooting

### Google Sign-In Not Working

- Verify SHA-1 fingerprint is added in Firebase Console
- Check that `google-services.json` is in `android/app/`
- Rebuild the app: `flutter clean && flutter pub get && flutter run`

### Firestore Permission Denied

- Verify security rules are deployed
- Check that user is authenticated
- Ensure user document exists in Firestore

### Firebase Not Initializing

- Verify `firebase_options.dart` exists
- Check that `Firebase.initializeApp()` is called before `runApp()`
- Ensure all Firebase dependencies are installed

## Production Checklist

- [ ] Update security rules for production
- [ ] Add SHA-1 for release keystore
- [ ] Set up proper error logging
- [ ] Configure Firebase App Check
- [ ] Set up Cloud Functions for reminders
- [ ] Enable Firebase Analytics
- [ ] Set up crash reporting
- [ ] Configure proper backup rules

## Resources

- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Firebase Authentication](https://firebase.google.com/docs/auth)

---

Need help? Check the [Firebase Community](https://firebase.google.com/community) or open an issue on GitHub.
