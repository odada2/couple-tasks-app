# Couple Tasks - A Loving Task Collaboration App for Couples

A Flutter mobile app designed to help couples collaborate on tasks in a friendly, supportive way. Built with Firebase/Firestore backend and inspired by relationship therapy principles from the Gottman Foundation.

## Features

### 🎯 Core Features
- **Google Sign-In Authentication** - Easy onboarding with Google OAuth
- **Couple Linking** - Connect with your partner via email
- **Shared Task Management** - Create, assign, and track tasks together
- **Loving Nudges** - Send encouraging emoji-based reminders
- **Progress Tracking** - Visual progress indicators for team motivation
- **Beautiful UI** - Warm, inviting design focused on positive communication

### 📱 Screens
1. **Onboarding** - Philosophy introduction (Communication, Teamwork, Celebration)
2. **Login** - Google/Apple Sign-In
3. **Couple Setup** - Link with partner
4. **Home** - Task list with progress tracking
5. **New Task** - Create tasks with assignment and due dates
6. **Task Detail** - View details and send nudges

## Tech Stack

- **Frontend**: Flutter 3.24.5
- **Backend**: Firebase
  - Firebase Auth (Google Sign-In)
  - Cloud Firestore (Database)
  - Firebase Cloud Messaging (Notifications - ready for implementation)
- **State Management**: Provider (ready for implementation)
- **UI**: Material Design 3 with custom theme

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── user_model.dart
│   ├── couple_model.dart
│   ├── task_model.dart
│   └── nudge_model.dart
├── screens/                  # UI screens
│   ├── onboarding_screen.dart
│   ├── login_screen.dart
│   ├── couple_setup_screen.dart
│   ├── home_screen.dart
│   ├── new_task_screen.dart
│   └── task_detail_screen.dart
├── services/                 # Business logic
│   ├── auth_service.dart
│   └── firestore_service.dart
├── utils/                    # Utilities
│   └── app_theme.dart
├── widgets/                  # Reusable widgets (ready for expansion)
└── providers/                # State management (ready for expansion)
```

## Firebase Setup

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Enable Google Analytics (optional)

### 2. Configure Firebase for Flutter

Install FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```

Configure Firebase:
```bash
flutterfire configure
```

This will:
- Create `firebase_options.dart`
- Configure iOS and Android apps
- Download configuration files

### 3. Enable Authentication
1. In Firebase Console, go to Authentication
2. Enable **Google Sign-In** provider
3. Add your app's SHA-1 fingerprint for Android

### 4. Set up Firestore Database
1. In Firebase Console, go to Firestore Database
2. Create database in production mode
3. Set up Security Rules (see below)

### 5. Create Firestore Indexes

Create composite indexes for queries:
1. Collection: `tasks`
   - Fields: `coupleId` (Ascending), `createdAt` (Descending)
2. Collection: `tasks`
   - Fields: `status` (Ascending), `dueDate` (Ascending)

## Installation & Running

### Prerequisites
- Flutter SDK 3.24.5 or higher
- Dart SDK 3.5.4 or higher
- Firebase project configured

### Install Dependencies
```bash
flutter pub get
```

### Run the App
```bash
# Run on connected device/emulator
flutter run

# Run on specific device
flutter run -d <device_id>

# Build for production
flutter build apk  # Android
flutter build ios  # iOS
```

## Firestore Data Models

### Users Collection
```json
{
  "displayName": "John Doe",
  "email": "john@example.com",
  "photoUrl": "https://...",
  "createdAt": "TIMESTAMP",
  "lastActiveAt": "TIMESTAMP",
  "coupleId": "couple_abc123",
  "notifications": {
    "nudgesEnabled": true,
    "remindersEnabled": true,
    "quietHours": {
      "start": "22:00",
      "end": "07:00"
    }
  },
  "deviceTokens": ["fcm_token_1"]
}
```

### Couples Collection
```json
{
  "partnerIds": ["userId1", "userId2"],
  "createdAt": "TIMESTAMP",
  "status": "active",
  "name": "John & Jane",
  "tone": "playful",
  "reminderWindowHours": 24
}
```

### Tasks Collection
```json
{
  "coupleId": "couple_abc123",
  "title": "Grocery shopping",
  "description": "Get items for dinner",
  "createdByUserId": "userId1",
  "assignedToUserId": "userId2",
  "status": "pending",
  "dueDate": "TIMESTAMP",
  "createdAt": "TIMESTAMP",
  "updatedAt": "TIMESTAMP",
  "completedAt": null,
  "lastReminderAt": null,
  "reminderCount": 0,
  "nudgesCount": 2
}
```

### Nudges Collection
```json
{
  "taskId": "task_123",
  "coupleId": "couple_abc123",
  "fromUserId": "userId1",
  "toUserId": "userId2",
  "emoji": "💛",
  "customMessage": "You got this!",
  "createdAt": "TIMESTAMP"
}
```

## Future Enhancements

### Phase 2 Features
- [ ] Push notifications with Firebase Cloud Messaging
- [ ] Automated reminder system (Cloud Functions)
- [ ] Celebration notifications on task completion
- [ ] Task categories and filters
- [ ] Calendar view
- [ ] Task templates
- [ ] Couple statistics and insights

### Phase 3 Features
- [ ] Apple Sign-In
- [ ] Custom nudge messages
- [ ] Quiet hours enforcement
- [ ] Multiple tone preferences
- [ ] Task attachments
- [ ] Recurring tasks
- [ ] Shared shopping lists

## Design Philosophy

This app is built around three core principles inspired by relationship therapy:

1. **Communication with Kindness** - Tools that help express needs without friction
2. **Teamwork over Taskwork** - Shared goals that bring couples closer
3. **Celebrating Each Other** - Recognition for small wins and big achievements

## License

MIT License - feel free to use this code for your own projects.

---

Built with ❤️ for couples who want to collaborate better
