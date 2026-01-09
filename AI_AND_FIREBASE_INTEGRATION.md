# AI & Firebase Integration Documentation

## Overview

This document describes the integration of **Gemini AI**, **Firebase Cloud Messaging (FCM)**, and **Firebase Analytics** into the Couple Tasks app. These services enhance the app with AI-powered features, push notifications, and comprehensive analytics tracking.

---

## Table of Contents

1. [Gemini AI Integration](#gemini-ai-integration)
2. [Firebase Cloud Messaging (FCM)](#firebase-cloud-messaging-fcm)
3. [Firebase Analytics](#firebase-analytics)
4. [Setup Instructions](#setup-instructions)
5. [Usage Examples](#usage-examples)
6. [Best Practices](#best-practices)
7. [Troubleshooting](#troubleshooting)

---

## Gemini AI Integration

### Overview

Gemini AI powers intelligent features in the Couple Tasks app, including:
- **Task Suggestions**: AI-generated task recommendations based on context
- **Smart Descriptions**: Enhanced task descriptions with helpful details
- **Loving Nudges**: Personalized, warm reminder messages
- **Relationship Insights**: Positive feedback on collaboration patterns
- **Smart Reminders**: Context-aware reminder text based on urgency

### Service: `GeminiService`

**Location**: `lib/services/gemini_service.dart`

### Key Features

#### 1. Task Suggestions
Generate AI-powered task suggestions based on couple's context.

```dart
final geminiService = GeminiService();
await geminiService.initialize(apiKey);

final suggestion = await geminiService.generateTaskSuggestion(
  'We have a dinner date planned this weekend'
);
```

#### 2. Loving Nudges
Create personalized, encouraging nudge messages.

```dart
final nudge = await geminiService.generateLovingNudge(
  taskTitle: 'Grocery shopping',
  partnerName: 'Alex',
  taskContext: 'For dinner party on Saturday',
);
// Result: "💛 Hey love, just a gentle reminder about grocery shopping!"
```

#### 3. Enhanced Descriptions
Improve task descriptions with AI suggestions.

```dart
final description = await geminiService.enhanceTaskDescription(
  'Plan anniversary celebration'
);
```

#### 4. Relationship Insights
Generate positive insights about collaboration.

```dart
final insight = await geminiService.generateRelationshipInsight(
  tasksCompleted: 25,
  tasksShared: 18,
  nudgesSent: 12,
);
```

#### 5. Smart Reminders
Create context-aware reminder messages.

```dart
final reminder = await geminiService.generateSmartReminder(
  taskTitle: 'Book restaurant',
  dueDate: DateTime.now().add(Duration(days: 2)),
  isOverdue: false,
);
```

### Configuration

**Model**: `gemini-2.0-flash-exp` (latest experimental model)

**Parameters**:
- Temperature: 0.7 (balanced creativity)
- Top K: 40
- Top P: 0.95
- Max Output Tokens: 1024

**Safety Settings**: Medium threshold for all categories

### API Key Management

⚠️ **IMPORTANT**: Never hardcode API keys in the app.

**Recommended approaches**:

1. **Firebase Remote Config** (Recommended for production)
```dart
final remoteConfig = FirebaseRemoteConfig.instance;
await remoteConfig.fetchAndActivate();
final apiKey = remoteConfig.getString('gemini_api_key');
```

2. **Environment Variables** (For development)
```dart
const apiKey = String.fromEnvironment('GEMINI_API_KEY');
```

3. **Secure Storage** (Alternative)
```dart
final storage = FlutterSecureStorage();
final apiKey = await storage.read(key: 'gemini_api_key');
```

### Get API Key

1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Create a new API key
3. Store it securely (never commit to Git)
4. Add to `.gitignore`: `*.env`, `*.key`

---

## Firebase Cloud Messaging (FCM)

### Overview

FCM enables push notifications for:
- Task reminders
- Task assignments
- Task completions
- Loving nudges
- Partner joining notifications

### Service: `NotificationService`

**Location**: `lib/services/notification_service.dart`

### Key Features

#### 1. Device Token Management
Automatically manages FCM tokens for each device.

```dart
final notificationService = NotificationService();
await notificationService.initialize();

// Save token for current user
await notificationService.saveFCMTokenForUser(userId);
```

#### 2. Notification Types

**Task Reminder**
```dart
final payload = NotificationService.createTaskReminderNotification(
  taskId: 'task123',
  taskTitle: 'Grocery shopping',
  partnerName: 'Alex',
);
```

**Task Assigned**
```dart
final payload = NotificationService.createTaskAssignedNotification(
  taskId: 'task123',
  taskTitle: 'Book restaurant',
  assignedBy: 'Alex',
);
```

**Task Completed**
```dart
final payload = NotificationService.createTaskCompletedNotification(
  taskId: 'task123',
  taskTitle: 'Grocery shopping',
  completedBy: 'Alex',
);
```

**Loving Nudge**
```dart
final payload = NotificationService.createNudgeNotification(
  taskId: 'task123',
  taskTitle: 'Grocery shopping',
  nudgeMessage: '💛 You got this!',
  fromPartner: 'Alex',
);
```

#### 3. Topic Subscriptions
Subscribe couples to shared notification topics.

```dart
// Both partners subscribe to the same topic
await notificationService.subscribeToCoupleTopic(coupleId);

// Unsubscribe when leaving couple
await notificationService.unsubscribeFromCoupleTopic(coupleId);
```

#### 4. Notification Handlers

**Foreground** (app is open)
```dart
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  // Display local notification
  // Update UI in real-time
});
```

**Background** (app is in background)
```dart
FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  // Navigate to relevant screen
});
```

**Terminated** (app was closed)
```dart
final message = await FirebaseMessaging.instance.getInitialMessage();
if (message != null) {
  // Handle notification that opened the app
}
```

### Platform Configuration

#### iOS Setup

1. **Enable capabilities in Xcode**:
   - Push Notifications
   - Background Modes → Remote notifications

2. **Upload APNs certificate** to Firebase Console:
   - Project Settings → Cloud Messaging → iOS app
   - Upload APNs Authentication Key or Certificate

3. **Update `Info.plist`**:
```xml
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
```

#### Android Setup

1. **Update `AndroidManifest.xml`**:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

2. **Add notification icon** (optional):
```xml
<meta-data
    android:name="com.google.firebase.messaging.default_notification_icon"
    android:resource="@drawable/ic_notification" />
```

3. **Google Services JSON** already configured

### Cloud Functions for Sending Notifications

**Example Cloud Function** (Node.js):

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Send notification when task is assigned
exports.sendTaskAssignedNotification = functions.firestore
  .document('tasks/{taskId}')
  .onCreate(async (snap, context) => {
    const task = snap.data();
    const assignedToId = task.assignedTo;
    
    // Get user's FCM token
    const userDoc = await admin.firestore()
      .collection('users')
      .doc(assignedToId)
      .get();
    
    const fcmToken = userDoc.data().fcmToken;
    
    if (!fcmToken) return;
    
    // Send notification
    const message = {
      notification: {
        title: 'New Task',
        body: `${task.createdByName} assigned you: ${task.title}`,
      },
      data: {
        type: 'task_assigned',
        taskId: context.params.taskId,
        taskTitle: task.title,
      },
      token: fcmToken,
    };
    
    await admin.messaging().send(message);
  });
```

---

## Firebase Analytics

### Overview

Firebase Analytics tracks user behavior and app usage for:
- User engagement and retention
- Feature usage patterns
- Task completion metrics
- Collaboration insights
- Error tracking

### Service: `AnalyticsService`

**Location**: `lib/services/analytics_service.dart`

### Key Event Categories

#### 1. Authentication Events

```dart
final analytics = AnalyticsService();
await analytics.initialize();

// User signs up
await analytics.logSignUp(method: 'google');

// User logs in
await analytics.logLogin(method: 'google');
```

#### 2. Onboarding Events

```dart
// Onboarding started
await analytics.logOnboardingStarted();

// Onboarding completed
await analytics.logOnboardingCompleted();

// Couple setup completed
await analytics.logCoupleSetupCompleted(
  coupleId: 'couple123',
  isCreator: true,
);
```

#### 3. Task Events

```dart
// Task created
await analytics.logTaskCreated(
  taskId: 'task123',
  assignedTo: 'both',
  hasDueDate: true,
  hasDescription: true,
);

// Task completed
await analytics.logTaskCompleted(
  taskId: 'task123',
  assignedTo: 'both',
  daysToComplete: 3,
  wasOverdue: false,
);

// Task deleted
await analytics.logTaskDeleted(
  taskId: 'task123',
  wasCompleted: false,
);
```

#### 4. Nudge Events

```dart
// Nudge sent
await analytics.logNudgeSent(
  taskId: 'task123',
  nudgeType: 'preset',
  message: '💛 You got this!',
);

// Nudge received
await analytics.logNudgeReceived(
  taskId: 'task123',
  fromPartner: 'Alex',
);
```

#### 5. Collaboration Metrics

```dart
// Shared task interaction
await analytics.logSharedTaskInteraction(
  taskId: 'task123',
  interactionType: 'complete',
);

// Collaboration milestone
await analytics.logCollaborationMilestone(
  milestoneType: '10_tasks',
  totalTasks: 10,
);
```

#### 6. AI Feature Events

```dart
// AI feature used
await analytics.logAIFeatureUsed(
  featureType: 'task_suggestion',
  wasSuccessful: true,
);

// AI suggestion accepted
await analytics.logAISuggestionAccepted(
  suggestionType: 'task_description',
);
```

#### 7. Screen View Events

```dart
// Log screen view
await analytics.logScreenView(
  screenName: 'home_screen',
  screenClass: 'HomeScreen',
);
```

#### 8. Engagement Events

```dart
// App opened
await analytics.logAppOpened(source: 'notification');

// Feature discovery
await analytics.logFeatureDiscovery(
  featureName: 'loving_nudges',
);

// Daily active user
await analytics.logDailyActive();
```

### User Properties

Set user properties for segmentation:

```dart
await analytics.setUserProperties(
  userId: 'user123',
  coupleId: 'couple456',
  isPremium: false,
);
```

### Navigation Tracking

Use `FirebaseAnalyticsObserver` for automatic screen tracking:

```dart
MaterialApp(
  navigatorObservers: [
    FirebaseAnalyticsObserver(analytics: analytics.analytics),
  ],
  // ...
);
```

### Viewing Analytics

1. Open [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Analytics** → **Dashboard**
4. View events, user properties, and custom reports

---

## Setup Instructions

### 1. Install Dependencies

Already added to `pubspec.yaml`:

```yaml
dependencies:
  # Firebase
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.3
  cloud_firestore: ^5.5.2
  firebase_messaging: ^15.1.5
  firebase_analytics: ^11.3.5
  
  # Gemini AI
  google_generative_ai: ^0.4.6
```

Run:
```bash
flutter pub get
```

### 2. Initialize Services in `main.dart`

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:couple_tasks/services/gemini_service.dart';
import 'package:couple_tasks/services/notification_service.dart';
import 'package:couple_tasks/services/analytics_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize Notification Service
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  // Initialize Analytics
  final analytics = AnalyticsService();
  await analytics.initialize();
  
  // Initialize Gemini AI (with secure API key)
  final geminiService = GeminiService();
  // Get API key from secure storage or Remote Config
  final apiKey = await getSecureApiKey();
  await geminiService.initialize(apiKey);
  
  runApp(MyApp(
    notificationService: notificationService,
    analytics: analytics,
    geminiService: geminiService,
  ));
}
```

### 3. Configure Firebase Project

1. **Enable Cloud Messaging**:
   - Firebase Console → Project Settings → Cloud Messaging
   - Note the Server Key for Cloud Functions

2. **Enable Analytics**:
   - Firebase Console → Analytics → Dashboard
   - Analytics is enabled by default

3. **Set up Cloud Functions** (for sending notifications):
   ```bash
   firebase init functions
   cd functions
   npm install firebase-admin
   ```

### 4. Get Gemini API Key

1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Create API key
3. Store securely (Firebase Remote Config recommended)

---

## Usage Examples

### Example 1: Complete Task Flow with Analytics

```dart
// User creates a task
final task = await firestoreService.createTask(
  title: 'Grocery shopping',
  assignedTo: 'both',
  dueDate: DateTime.now().add(Duration(days: 2)),
);

// Log analytics
await analytics.logTaskCreated(
  taskId: task.id,
  assignedTo: 'both',
  hasDueDate: true,
);

// Send notification to partner
final payload = NotificationService.createTaskAssignedNotification(
  taskId: task.id,
  taskTitle: task.title,
  assignedBy: currentUser.name,
);
// (Send via Cloud Function)

// User completes the task
await firestoreService.completeTask(task.id);

// Log analytics
await analytics.logTaskCompleted(
  taskId: task.id,
  assignedTo: 'both',
  daysToComplete: 1,
);

// Send completion notification
final completionPayload = NotificationService.createTaskCompletedNotification(
  taskId: task.id,
  taskTitle: task.title,
  completedBy: currentUser.name,
);
```

### Example 2: AI-Powered Nudge

```dart
// User wants to send a loving nudge
final task = await firestoreService.getTask(taskId);

// Generate AI-powered nudge message
final nudgeMessage = await geminiService.generateLovingNudge(
  taskTitle: task.title,
  partnerName: partner.name,
);

// Save nudge to Firestore
await firestoreService.addNudge(
  taskId: task.id,
  message: nudgeMessage,
  fromUserId: currentUser.id,
);

// Log analytics
await analytics.logNudgeSent(
  taskId: task.id,
  nudgeType: 'ai_generated',
  message: nudgeMessage,
);

// Send notification
final payload = NotificationService.createNudgeNotification(
  taskId: task.id,
  taskTitle: task.title,
  nudgeMessage: nudgeMessage,
  fromPartner: currentUser.name,
);
```

### Example 3: AI Task Suggestions

```dart
// User opens task creation screen
await analytics.logScreenView(screenName: 'new_task_screen');

// User requests AI suggestions
await analytics.logAIFeatureUsed(
  featureType: 'task_suggestion',
  wasSuccessful: true,
);

final suggestions = await geminiService.generateTaskSuggestion(
  'We have a dinner party this Saturday'
);

// User accepts a suggestion
await analytics.logAISuggestionAccepted(
  suggestionType: 'task_from_context',
);

// Create task from suggestion
final task = await firestoreService.createTask(
  title: suggestions[0],
  assignedTo: 'both',
);
```

---

## Best Practices

### Gemini AI

1. **Rate Limiting**: Implement rate limiting to avoid API quota exhaustion
2. **Error Handling**: Always wrap AI calls in try-catch blocks
3. **Fallback Messages**: Provide default messages if AI fails
4. **User Control**: Allow users to edit AI-generated content
5. **Privacy**: Never send sensitive personal information to AI

### Firebase Cloud Messaging

1. **Token Management**: Update tokens when they refresh
2. **Topic Naming**: Use consistent naming (e.g., `couple_{coupleId}`)
3. **Notification Channels**: Use appropriate channels for Android
4. **Silent Notifications**: Use data-only messages for background updates
5. **Delivery Reports**: Track notification delivery success

### Firebase Analytics

1. **Event Naming**: Use snake_case (e.g., `task_created`)
2. **Parameter Limits**: Max 25 parameters per event
3. **PII Protection**: Never log personally identifiable information
4. **Custom Dimensions**: Use user properties for segmentation
5. **Event Volume**: Avoid logging too frequently (impacts quota)

---

## Troubleshooting

### Gemini AI Issues

**Problem**: API key not working
- **Solution**: Verify key at [Google AI Studio](https://makersuite.google.com/app/apikey)
- Check API is enabled in Google Cloud Console

**Problem**: Rate limit exceeded
- **Solution**: Implement exponential backoff
- Consider upgrading API quota

**Problem**: Empty responses
- **Solution**: Check safety settings
- Verify prompt format

### FCM Issues

**Problem**: Notifications not received on iOS
- **Solution**: 
  - Verify APNs certificate in Firebase Console
  - Enable Push Notifications in Xcode
  - Check device token is saved to Firestore

**Problem**: Notifications not received on Android
- **Solution**:
  - Verify `google-services.json` is up to date
  - Check app is not in battery optimization
  - Test with Firebase Console test message

**Problem**: Background handler not working
- **Solution**:
  - Ensure handler is top-level function
  - Add `@pragma('vm:entry-point')` annotation
  - Check Android manifest permissions

### Analytics Issues

**Problem**: Events not appearing in console
- **Solution**:
  - Wait 24 hours for data processing
  - Use DebugView for real-time testing
  - Verify analytics is enabled

**Problem**: User properties not set
- **Solution**:
  - Call `setUserProperties()` after authentication
  - Check property name format (snake_case)
  - Verify user ID is set

---

## Security Considerations

### API Keys

- ✅ Store in Firebase Remote Config
- ✅ Use environment variables for development
- ❌ Never commit to Git
- ❌ Never hardcode in source code

### Notifications

- ✅ Validate notification payloads
- ✅ Use HTTPS for all communication
- ✅ Implement server-side authorization
- ❌ Never trust client-side data

### Analytics

- ✅ Anonymize user data
- ✅ Follow GDPR/privacy regulations
- ✅ Provide opt-out mechanism
- ❌ Never log passwords or sensitive data

---

## Future Enhancements

### Gemini AI
- [ ] Multi-turn conversations
- [ ] Image analysis for task photos
- [ ] Voice input for task creation
- [ ] Personalized learning from couple's patterns

### FCM
- [ ] Scheduled notifications
- [ ] Rich media notifications (images, actions)
- [ ] Notification preferences per user
- [ ] Smart notification timing

### Analytics
- [ ] Custom dashboards
- [ ] Funnel analysis
- [ ] A/B testing integration
- [ ] Predictive analytics for task completion

---

## Resources

### Documentation
- [Gemini API Docs](https://ai.google.dev/docs)
- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [Firebase Analytics](https://firebase.google.com/docs/analytics)

### Tools
- [Google AI Studio](https://makersuite.google.com/)
- [Firebase Console](https://console.firebase.google.com/)
- [Analytics DebugView](https://firebase.google.com/docs/analytics/debugview)

### Support
- [Firebase Support](https://firebase.google.com/support)
- [Gemini API Forum](https://discuss.ai.google.dev/)
- [Flutter Community](https://flutter.dev/community)

---

## Summary

The Couple Tasks app now includes:

✅ **Gemini AI** - AI-powered task suggestions, nudges, and insights  
✅ **Firebase Cloud Messaging** - Push notifications for tasks and reminders  
✅ **Firebase Analytics** - Comprehensive tracking and user insights  

All services are production-ready and follow best practices for security, performance, and user experience.
