# Couple Tasks - Project Overview

## 🎯 Project Summary

**Couple Tasks** is a Flutter mobile application designed to help couples collaborate on household tasks and chores in a friendly, supportive manner. The app emphasizes positive communication, teamwork, and celebration, drawing inspiration from relationship therapy principles (particularly the Gottman Foundation).

**GitHub Repository**: https://github.com/odada2/couple-tasks-app

## 🌟 Key Features Implemented

### ✅ Authentication & Onboarding
- **Onboarding Flow**: Three-screen philosophy introduction
  - Communication with Kindness
  - Teamwork over Taskwork
  - Celebrating Each Other
- **Google Sign-In**: Seamless authentication via Firebase Auth
- **Couple Linking**: Connect with partner via email

### ✅ Task Management
- **Create Tasks**: Add tasks with title, description, due date
- **Task Assignment**: Assign to self, partner, or both
- **Task Status**: Track pending and completed tasks
- **Task Details**: View full task information
- **Delete Tasks**: Remove unwanted tasks

### ✅ Loving Nudge System
- **Send Nudges**: 6 pre-defined emoji-based encouragement messages
- **Nudge Tracking**: Count nudges per task
- **Friendly UI**: Warm, inviting nudge interface

### ✅ User Interface
- **Custom Theme**: Pink/peach color scheme matching design mockups
- **Progress Tracking**: Visual progress indicators
- **Responsive Design**: Clean, modern Material Design 3
- **Google Fonts**: Inter font family for professional look

## 🏗️ Architecture

### Technology Stack
- **Frontend**: Flutter 3.24.5 / Dart 3.5.4
- **Backend**: Firebase
  - Firebase Authentication (Google Sign-In)
  - Cloud Firestore (NoSQL Database)
  - Firebase Cloud Messaging (Ready for notifications)
- **State Management**: Provider (structure ready)
- **UI Framework**: Material Design 3

### Project Structure
```
lib/
├── main.dart                      # App entry point with Firebase init
├── models/                        # Data models
│   ├── user_model.dart           # User with notifications preferences
│   ├── couple_model.dart         # Couple relationship
│   ├── task_model.dart           # Task with status tracking
│   └── nudge_model.dart          # Nudge messages
├── screens/                       # UI screens
│   ├── onboarding_screen.dart    # 3-page philosophy intro
│   ├── login_screen.dart         # Google/Apple sign-in
│   ├── couple_setup_screen.dart  # Partner linking
│   ├── home_screen.dart          # Task list with progress
│   ├── new_task_screen.dart      # Task creation
│   └── task_detail_screen.dart   # Task details + nudges
├── services/                      # Business logic
│   ├── auth_service.dart         # Authentication
│   └── firestore_service.dart    # Database operations
├── utils/                         # Utilities
│   └── app_theme.dart            # Custom theme
├── widgets/                       # Reusable widgets (ready)
└── providers/                     # State management (ready)
```

## 📊 Firestore Data Model

### Collections

#### `users`
- User profile and preferences
- Device tokens for notifications
- Couple ID reference

#### `couples`
- Links two partner user IDs
- Couple-level settings (tone, reminder preferences)
- Relationship metadata

#### `tasks`
- Couple-scoped tasks
- Assignment, status, due dates
- Nudge and reminder counters

#### `nudges`
- Emoji-based encouragement messages
- Tracks who sent to whom
- Associated with specific tasks

## 🔐 Security

### Firestore Security Rules
- Users can only read/write their own data
- Couples can be accessed by both partners
- Tasks and nudges are couple-scoped
- Comprehensive validation rules in `firestore.rules`

## 🚀 Getting Started

### Prerequisites
1. Flutter SDK 3.24.5+
2. Firebase account
3. Android Studio / Xcode (for mobile development)

### Setup Steps

1. **Clone Repository**
   ```bash
   git clone https://github.com/odada2/couple-tasks-app.git
   cd couple-tasks-app
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase
   flutterfire configure
   ```

4. **Set Up Firebase Services**
   - Enable Google Sign-In in Firebase Console
   - Create Firestore database
   - Deploy security rules from `firestore.rules`
   - Create required indexes (see `FIREBASE_SETUP.md`)

5. **Run the App**
   ```bash
   flutter run
   ```

For detailed Firebase setup instructions, see **FIREBASE_SETUP.md**.

## 📱 App Flow

### First-Time User Journey
1. **Onboarding** → View philosophy screens
2. **Login** → Sign in with Google
3. **Couple Setup** → Enter partner's email to link
4. **Home** → View shared tasks (empty initially)
5. **Create Task** → Add first task together
6. **Task Detail** → Send loving nudge to partner

### Returning User Journey
1. **Auto-Login** → Firebase Auth persistence
2. **Home** → View task list with progress
3. **Manage Tasks** → Create, complete, nudge
4. **Celebrate** → See completion animations

## 🎨 Design Philosophy

The app follows three core principles:

### 1. Communication with Kindness
- Speak from the heart
- Express needs without friction
- Tools designed for positive communication

### 2. Teamwork over Taskwork
- Shared goals bring couples closer
- Tackle chores together
- Make time for what matters

### 3. Celebrating Each Other
- Small wins deserve recognition
- Loving nudges instead of nagging
- Celebrate every completed task

## 🔮 Future Enhancements

### Phase 2 (Immediate Next Steps)
- [ ] **Push Notifications**: Firebase Cloud Messaging integration
- [ ] **Automated Reminders**: Cloud Functions for scheduled reminders
- [ ] **Celebration Animations**: Enhanced completion feedback
- [ ] **Task Filters**: Filter by status, assignment, due date
- [ ] **Search**: Find tasks quickly
- [ ] **Apple Sign-In**: iOS authentication

### Phase 3 (Advanced Features)
- [ ] **Task Categories**: Organize by type (chores, errands, etc.)
- [ ] **Recurring Tasks**: Weekly/monthly repeating tasks
- [ ] **Task Templates**: Pre-defined common tasks
- [ ] **Calendar View**: Visual timeline of tasks
- [ ] **Couple Statistics**: Track completion rates and patterns
- [ ] **Custom Nudge Messages**: Personalized encouragement
- [ ] **Quiet Hours**: Respect partner's downtime
- [ ] **Multiple Tone Preferences**: Playful, neutral, spiritual

### Phase 4 (Advanced Integrations)
- [ ] **Shared Shopping Lists**: Grocery and shopping management
- [ ] **Task Attachments**: Photos and files
- [ ] **Voice Notes**: Audio nudges and messages
- [ ] **Integration with Calendar Apps**: Sync with Google Calendar
- [ ] **Widgets**: Home screen task widgets
- [ ] **Wear OS / Apple Watch**: Quick task completion

## 🐛 Known Limitations

### Current Version (v1.0.0)
- No push notifications (structure ready)
- No automated reminders (requires Cloud Functions)
- No Apple Sign-In (Google only)
- No task editing (only create/delete)
- No task categories or filters
- No recurring tasks
- Partner must sign up before linking

### Technical Debt
- State management could be improved with Provider
- Error handling needs enhancement
- Offline support not implemented
- Unit tests not written
- Integration tests not written

## 📚 Documentation Files

- **README.md**: Quick start guide and feature overview
- **FIREBASE_SETUP.md**: Detailed Firebase configuration guide
- **PROJECT_OVERVIEW.md**: This file - comprehensive project documentation
- **firestore.rules**: Firestore security rules
- **pubspec.yaml**: Flutter dependencies

## 🤝 Contributing

This is a personal project, but suggestions are welcome! To contribute:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

MIT License - Free to use and modify

## 🙏 Acknowledgments

- **Gottman Foundation**: Relationship therapy principles
- **Flutter Team**: Amazing framework
- **Firebase Team**: Excellent backend services
- **Design Inspiration**: From provided mockups

## 📞 Support

For questions or issues:
- Open a GitHub issue
- Check Firebase documentation
- Review Flutter documentation

---

**Built with ❤️ for couples who want to collaborate better**

Repository: https://github.com/odada2/couple-tasks-app
