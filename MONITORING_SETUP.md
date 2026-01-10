# Firebase Crashlytics & Performance Monitoring Setup

**Complete guide for error tracking and performance monitoring in Couple Tasks app**

---

## Overview

The Couple Tasks app now includes **Firebase Crashlytics** for crash reporting and **Firebase Performance Monitoring** for performance analysis. This document explains how to set up, use, and monitor these services.

---

## Table of Contents

1. [What's Implemented](#whats-implemented)
2. [Firebase Console Setup](#firebase-console-setup)
3. [Usage Guide](#usage-guide)
4. [Monitoring Service API](#monitoring-service-api)
5. [Best Practices](#best-practices)
6. [Viewing Reports](#viewing-reports)
7. [Troubleshooting](#troubleshooting)

---

## What's Implemented

### ✅ Firebase Crashlytics

**Automatic Crash Reporting**:
- All uncaught Flutter errors
- All uncaught asynchronous errors
- Fatal crashes with full stack traces
- Non-fatal errors with context

**Custom Logging**:
- Error logging with context
- Breadcrumb logging
- User identification
- Custom key-value pairs

**Features**:
- Automatic symbolication (debug symbols)
- Stack trace deobfuscation
- User impact analysis
- Crash-free users percentage

### ✅ Firebase Performance Monitoring

**Automatic Monitoring**:
- App start time
- Screen rendering performance
- Network requests (HTTP/HTTPS)

**Custom Traces**:
- Database operations
- Task CRUD operations
- Sync operations
- AI content generation
- Subscription purchases

**Custom Metrics**:
- Operation duration
- Item counts
- Success/failure rates
- Custom attributes

---

## Firebase Console Setup

### Step 1: Enable Crashlytics

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Navigate to **Crashlytics** in the left menu
4. Click **Enable Crashlytics**
5. Wait for initialization (may take a few minutes)

### Step 2: Enable Performance Monitoring

1. In Firebase Console, navigate to **Performance**
2. Click **Get Started**
3. Performance Monitoring is now enabled

### Step 3: Configure Android

**Add to `android/app/build.gradle`**:

```gradle
plugins {
    id 'com.android.application'
    id 'kotlin-android'
    id 'dev.flutter.flutter-gradle-plugin'
    id 'com.google.gms.google-services'  // Add this
    id 'com.google.firebase.crashlytics'  // Add this
    id 'com.google.firebase.firebase-perf'  // Add this
}

android {
    // ... existing config

    buildTypes {
        release {
            // Enable Crashlytics mapping file upload
            firebaseCrashlytics {
                mappingFileUploadEnabled true
            }
            
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
        }
    }
}

dependencies {
    // Firebase dependencies are already in pubspec.yaml
}
```

**Add to `android/build.gradle`**:

```gradle
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
        classpath 'com.google.gms:google-services:4.4.0'
        classpath 'com.google.firebase:firebase-crashlytics-gradle:2.9.9'
        classpath 'com.google.firebase:perf-plugin:1.4.2'
    }
}
```

### Step 4: Configure iOS

**Add to `ios/Podfile`**:

```ruby
# Uncomment this line to define a global platform for your project
platform :ios, '12.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  
  # Add Firebase Crashlytics
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Performance'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
  end
end
```

**Run**:
```bash
cd ios
pod install
cd ..
```

**Add build phase in Xcode**:

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Runner** project → **Runner** target
3. Go to **Build Phases**
4. Click **+** → **New Run Script Phase**
5. Add script:
   ```bash
   "${PODS_ROOT}/FirebaseCrashlytics/run"
   ```
6. Move this phase **before** "Compile Sources"

### Step 5: Upload Debug Symbols

**Android**:
Debug symbols are automatically uploaded when you build a release APK/AAB.

**iOS**:
```bash
# Build with debug symbols
flutter build ios --release

# Symbols are automatically uploaded via the run script
```

---

## Usage Guide

### Basic Error Logging

```dart
import 'package:couple_tasks/services/monitoring_service.dart';

final monitoring = MonitoringService.instance;

// Log a non-fatal error
try {
  await riskyOperation();
} catch (e, stackTrace) {
  await monitoring.logError(
    e,
    stackTrace,
    reason: 'Failed to perform operation',
    context: {
      'user_id': userId,
      'operation': 'create_task',
    },
  );
}
```

### Performance Tracing

```dart
// Manual trace
final trace = await monitoring.startTrace('load_tasks');
try {
  final tasks = await loadTasks();
  await monitoring.setTraceMetric(trace, 'task_count', tasks.length);
} finally {
  await monitoring.stopTrace(trace);
}

// Automatic trace (recommended)
final tasks = await monitoring.traceAsync(
  'load_tasks',
  () => loadTasks(),
  attributes: {'couple_id': coupleId},
);
```

### User Context

```dart
// Set user ID for crash reports
await monitoring.setUserId(user.id);

// Add custom keys
await monitoring.setCustomKey('user_email', user.email);
await monitoring.setCustomKey('has_partner', user.coupleId != null);
await monitoring.setCustomKey('subscription_status', 'premium');
```

### Breadcrumb Logging

```dart
// Log user actions for debugging
await monitoring.log('User opened task detail screen');
await monitoring.log('User clicked send nudge button');
await monitoring.log('Task marked as complete');
```

---

## Monitoring Service API

### Error Logging

```dart
// Log non-fatal error
Future<void> logError(
  dynamic error,
  StackTrace? stackTrace, {
  String? reason,
  Map<String, dynamic>? context,
})

// Log fatal error
Future<void> logFatalError(
  dynamic error,
  StackTrace? stackTrace, {
  String? reason,
})

// Log message (breadcrumb)
Future<void> log(String message)
```

### User Context

```dart
// Set user identifier
Future<void> setUserId(String userId)

// Set custom key-value pair
Future<void> setCustomKey(String key, dynamic value)
```

### Performance Traces

```dart
// Start a trace
Future<Trace> startTrace(String traceName)

// Stop a trace
Future<void> stopTrace(Trace trace)

// Add metric to trace
Future<void> setTraceMetric(Trace trace, String metricName, int value)

// Increment metric
Future<void> incrementTraceMetric(Trace trace, String metricName)

// Add attribute to trace
Future<void> setTraceAttribute(Trace trace, String attributeName, String value)
```

### Convenience Methods

```dart
// Wrap async operation with trace
Future<T> traceAsync<T>(
  String traceName,
  Future<T> Function() operation, {
  Map<String, String>? attributes,
})

// Wrap sync operation with error handling
T? traceSync<T>(
  String operationName,
  T Function() operation, {
  T? defaultValue,
})
```

### HTTP Monitoring

```dart
// Create HTTP metric
HttpMetric httpMetric({
  required String url,
  required HttpMethod method,
})

// Example usage
final metric = monitoring.httpMetric(
  url: 'https://api.example.com/tasks',
  method: HttpMethod.Get,
);
await metric.start();
// ... make request
metric.responseCode = 200;
metric.responsePayloadSize = 1024;
await metric.stop();
```

---

## Best Practices

### 1. Use Predefined Trace Names

```dart
// Use constants for consistency
await monitoring.traceAsync(
  MonitoringService.traceLoadTasks,  // ✅ Good
  () => loadTasks(),
);

// Don't use random strings
await monitoring.traceAsync(
  'load_tasks_123',  // ❌ Bad
  () => loadTasks(),
);
```

### 2. Add Context to Errors

```dart
// Include relevant context
await monitoring.logError(
  e,
  stackTrace,
  reason: 'Failed to create task',
  context: {
    'task_title': task.title,
    'couple_id': task.coupleId,
    'user_id': userId,
  },
);
```

### 3. Set User Context Early

```dart
// Set user context after login
await monitoring.setUserId(user.id);
await monitoring.setCustomKey('user_email', user.email);
await monitoring.setCustomKey('subscription_tier', user.subscriptionTier);
```

### 4. Use Attributes for Filtering

```dart
// Add attributes to traces for filtering in console
await monitoring.traceAsync(
  'load_tasks',
  () => loadTasks(),
  attributes: {
    'couple_id': coupleId,
    'filter': 'active',
    'sort': 'date',
  },
);
```

### 5. Monitor Critical Paths

Focus on monitoring:
- App startup
- User authentication
- Data loading
- Sync operations
- Subscription purchases
- AI content generation

### 6. Don't Over-Monitor

Avoid:
- Tracing every single function
- Logging every user action
- Creating too many custom metrics

Focus on:
- Critical user flows
- Performance bottlenecks
- Error-prone operations

---

## Predefined Traces

The `MonitoringService` includes predefined trace names:

```dart
static const String traceAppStart = 'app_start';
static const String traceLogin = 'user_login';
static const String traceLoadTasks = 'load_tasks';
static const String traceCreateTask = 'create_task';
static const String traceUpdateTask = 'update_task';
static const String traceDeleteTask = 'delete_task';
static const String traceSyncData = 'sync_data';
static const String traceLoadPartner = 'load_partner';
static const String traceSendNudge = 'send_nudge';
static const String traceGenerateAI = 'generate_ai_content';
static const String tracePurchaseSubscription = 'purchase_subscription';
```

Use these for consistency across the app.

---

## Viewing Reports

### Crashlytics Dashboard

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Navigate to **Crashlytics**

**Key Metrics**:
- **Crash-free users**: Percentage of users not experiencing crashes
- **Crash-free sessions**: Percentage of sessions without crashes
- **Impacted users**: Number of users affected by crashes
- **Events**: Total crash occurrences

**Features**:
- Group crashes by type
- View stack traces
- See user impact
- Track crash trends
- Filter by app version, OS version, device

### Performance Dashboard

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Navigate to **Performance**

**Automatic Traces**:
- **App start**: Time from app launch to first screen
- **Screen rendering**: Frame rendering performance
- **Network requests**: HTTP request duration

**Custom Traces**:
- View all custom traces you've created
- See duration percentiles (50th, 90th, 99th)
- Compare across app versions
- Filter by attributes

**Key Metrics**:
- **Duration**: How long operations take
- **Success rate**: Percentage of successful operations
- **Network performance**: Request/response times

---

## Troubleshooting

### Crashes Not Appearing

**Issue**: Crashes aren't showing up in Firebase Console

**Solutions**:
1. **Wait 5-10 minutes**: Crashes can take time to appear
2. **Check Crashlytics is enabled**:
   ```dart
   final enabled = await monitoring.isCrashCollectionEnabled();
   print('Crashlytics enabled: $enabled');
   ```
3. **Force a test crash**:
   ```dart
   monitoring.forceCrash();  // ⚠️ Only for testing!
   ```
4. **Check debug symbols uploaded**: Ensure you've built a release build
5. **Verify Firebase configuration**: Ensure `google-services.json` and `GoogleService-Info.plist` are present

### Performance Traces Not Showing

**Issue**: Custom traces aren't appearing in Performance dashboard

**Solutions**:
1. **Wait 1-2 hours**: Performance data can take longer to process
2. **Check Performance Monitoring is enabled**:
   ```dart
   final enabled = await monitoring.isPerformanceCollectionEnabled();
   print('Performance enabled: $enabled');
   ```
3. **Ensure trace is stopped**: Always call `stopTrace()`
4. **Check trace duration**: Very short traces (<1ms) may not appear
5. **Verify network connection**: Data is uploaded when online

### Symbols Not Uploaded (Android)

**Issue**: Stack traces are obfuscated

**Solutions**:
1. **Enable mapping file upload** in `build.gradle`:
   ```gradle
   firebaseCrashlytics {
       mappingFileUploadEnabled true
   }
   ```
2. **Build release APK/AAB**: Symbols are only uploaded for release builds
3. **Check Gradle logs**: Look for Crashlytics upload confirmation

### Symbols Not Uploaded (iOS)

**Issue**: Stack traces show memory addresses instead of function names

**Solutions**:
1. **Verify run script**: Ensure Crashlytics run script is in Build Phases
2. **Check script runs before compilation**: Move script phase up
3. **Build with Xcode**: Symbols may not upload with `flutter build ios`
4. **Manual upload**:
   ```bash
   /path/to/pods/FirebaseCrashlytics/upload-symbols \
     -gsp /path/to/GoogleService-Info.plist \
     -p ios /path/to/dSYMs
   ```

---

## Testing

### Test Crashlytics

```dart
// Force a test crash (⚠️ will crash the app!)
MonitoringService.instance.forceCrash();

// Log a test error
try {
  throw Exception('Test error for Crashlytics');
} catch (e, stackTrace) {
  await MonitoringService.instance.logError(
    e,
    stackTrace,
    reason: 'Testing Crashlytics',
  );
}
```

### Test Performance Monitoring

```dart
// Create a test trace
final trace = await MonitoringService.instance.startTrace('test_trace');
await Future.delayed(Duration(seconds: 2));
await MonitoringService.instance.setTraceMetric(trace, 'test_metric', 42);
await MonitoringService.instance.stopTrace(trace);
```

---

## Production Checklist

Before launching to production:

- [ ] Crashlytics enabled in Firebase Console
- [ ] Performance Monitoring enabled in Firebase Console
- [ ] Debug symbols uploaded (Android & iOS)
- [ ] Test crash appears in Crashlytics dashboard
- [ ] Test trace appears in Performance dashboard
- [ ] User context set after login
- [ ] Critical operations monitored
- [ ] Error handling added to all async operations
- [ ] Breadcrumb logging added to key user actions

---

## Resources

- [Firebase Crashlytics Documentation](https://firebase.google.com/docs/crashlytics)
- [Firebase Performance Monitoring Documentation](https://firebase.google.com/docs/perf-mon)
- [FlutterFire Crashlytics](https://firebase.flutter.dev/docs/crashlytics/overview)
- [FlutterFire Performance](https://firebase.flutter.dev/docs/performance/overview)

---

## Support

For issues or questions:
1. Check Firebase Console for error details
2. Review Crashlytics dashboard for crash patterns
3. Analyze Performance dashboard for bottlenecks
4. Refer to this documentation

---

**Document Version**: 1.0  
**Last Updated**: January 9, 2026  
**Prepared By**: Manus AI Development Team
