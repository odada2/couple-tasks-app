import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Background message handler (must be top-level function)
/// 
/// This function handles notifications when the app is terminated
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📬 Background message received: ${message.messageId}');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Data: ${message.data}');
}

/// Service for managing Firebase Cloud Messaging (FCM) push notifications
/// 
/// This service handles:
/// - Device token registration
/// - Foreground notification display
/// - Background notification handling
/// - Notification permissions
/// - Topic subscriptions for couple-specific notifications
/// 
/// Usage:
/// ```dart
/// final notificationService = NotificationService();
/// await notificationService.initialize();
/// ```
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String? _fcmToken;
  bool _isInitialized = false;

  /// Get the current FCM token
  String? get fcmToken => _fcmToken;

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the notification service
  /// 
  /// This should be called early in the app lifecycle,
  /// typically in main() after Firebase initialization
  Future<void> initialize() async {
    try {
      print('🔔 Initializing notification service...');

      // Request notification permissions (iOS)
      final settings = await _requestPermission();
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ Notification permissions granted');
        
        // Get FCM token
        await _getFCMToken();
        
        // Set up foreground notification handler
        _setupForegroundNotificationHandler();
        
        // Set up notification tap handlers
        _setupNotificationTapHandlers();
        
        // Set up token refresh listener
        _setupTokenRefreshListener();
        
        _isInitialized = true;
        print('✅ Notification service initialized successfully');
      } else {
        print('⚠️  Notification permissions denied');
        _isInitialized = false;
      }
    } catch (e) {
      print('❌ Error initializing notification service: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  /// Request notification permissions from the user
  Future<NotificationSettings> _requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('📱 Permission status: ${settings.authorizationStatus}');
      return settings;
    } catch (e) {
      print('❌ Error requesting permissions: $e');
      rethrow;
    }
  }

  /// Get and store the FCM token
  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      
      if (_fcmToken != null) {
        print('🔑 FCM Token: $_fcmToken');
        // Token will be saved to Firestore when user logs in
      } else {
        print('⚠️  Failed to get FCM token');
      }
    } catch (e) {
      print('❌ Error getting FCM token: $e');
      rethrow;
    }
  }

  /// Save FCM token to Firestore for the current user
  /// 
  /// Call this after user authentication to enable push notifications
  Future<void> saveFCMTokenForUser(String userId) async {
    if (_fcmToken == null) {
      print('⚠️  No FCM token available to save');
      return;
    }

    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': _fcmToken,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ FCM token saved for user: $userId');
    } catch (e) {
      print('❌ Error saving FCM token: $e');
      // Don't rethrow - this is not critical
    }
  }

  /// Set up foreground notification handler
  /// 
  /// Displays notifications when app is in foreground
  void _setupForegroundNotificationHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📬 Foreground message received: ${message.messageId}');
      
      final notification = message.notification;
      final android = message.notification?.android;
      final apple = message.notification?.apple;

      if (notification != null) {
        print('📨 Notification:');
        print('  Title: ${notification.title}');
        print('  Body: ${notification.body}');
        print('  Data: ${message.data}');

        // TODO: Show local notification using flutter_local_notifications
        // For now, just log the notification
        _handleNotificationData(message.data);
      }
    });
  }

  /// Set up notification tap handlers
  /// 
  /// Handles what happens when user taps a notification
  void _setupNotificationTapHandlers() {
    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📬 Notification tapped (app in background): ${message.messageId}');
      _handleNotificationTap(message);
    });

    // Handle notification tap when app was terminated
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('📬 Notification tapped (app was terminated): ${message.messageId}');
        _handleNotificationTap(message);
      }
    });
  }

  /// Set up token refresh listener
  /// 
  /// Updates token in Firestore when it changes
  void _setupTokenRefreshListener() {
    _messaging.onTokenRefresh.listen((String newToken) {
      print('🔄 FCM token refreshed: $newToken');
      _fcmToken = newToken;
      // TODO: Update token in Firestore for current user
    });
  }

  /// Handle notification data payload
  void _handleNotificationData(Map<String, dynamic> data) {
    final type = data['type'];
    
    switch (type) {
      case 'task_reminder':
        print('📋 Task reminder notification');
        // TODO: Navigate to task detail
        break;
      case 'task_assigned':
        print('✅ Task assigned notification');
        // TODO: Navigate to task detail
        break;
      case 'task_completed':
        print('🎉 Task completed notification');
        // TODO: Show celebration
        break;
      case 'nudge_received':
        print('💛 Loving nudge received');
        // TODO: Navigate to task with nudge
        break;
      case 'partner_joined':
        print('👥 Partner joined notification');
        // TODO: Navigate to home
        break;
      default:
        print('📬 Unknown notification type: $type');
    }
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    _handleNotificationData(data);
  }

  /// Subscribe to a topic for couple-specific notifications
  /// 
  /// Both partners in a couple should subscribe to the same topic
  /// to receive notifications about shared tasks
  Future<void> subscribeToCoupleTopic(String coupleId) async {
    try {
      await _messaging.subscribeToTopic('couple_$coupleId');
      print('✅ Subscribed to couple topic: couple_$coupleId');
    } catch (e) {
      print('❌ Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from couple topic
  Future<void> unsubscribeFromCoupleTopic(String coupleId) async {
    try {
      await _messaging.unsubscribeFromTopic('couple_$coupleId');
      print('✅ Unsubscribed from couple topic: couple_$coupleId');
    } catch (e) {
      print('❌ Error unsubscribing from topic: $e');
    }
  }

  /// Send a notification to a specific user
  /// 
  /// This should be called from Cloud Functions, not from the client app
  /// This is just a helper method to show the expected data structure
  static Map<String, dynamic> createNotificationPayload({
    required String title,
    required String body,
    required String type,
    Map<String, String>? additionalData,
  }) {
    return {
      'notification': {
        'title': title,
        'body': body,
        'sound': 'default',
      },
      'data': {
        'type': type,
        'timestamp': DateTime.now().toIso8601String(),
        ...?additionalData,
      },
      'priority': 'high',
    };
  }

  /// Create task reminder notification payload
  static Map<String, dynamic> createTaskReminderNotification({
    required String taskId,
    required String taskTitle,
    required String partnerName,
  }) {
    return createNotificationPayload(
      title: 'Task Reminder',
      body: '$partnerName sent you a loving reminder about: $taskTitle',
      type: 'task_reminder',
      additionalData: {
        'taskId': taskId,
        'taskTitle': taskTitle,
      },
    );
  }

  /// Create task assigned notification payload
  static Map<String, dynamic> createTaskAssignedNotification({
    required String taskId,
    required String taskTitle,
    required String assignedBy,
  }) {
    return createNotificationPayload(
      title: 'New Task',
      body: '$assignedBy assigned you: $taskTitle',
      type: 'task_assigned',
      additionalData: {
        'taskId': taskId,
        'taskTitle': taskTitle,
      },
    );
  }

  /// Create task completed notification payload
  static Map<String, dynamic> createTaskCompletedNotification({
    required String taskId,
    required String taskTitle,
    required String completedBy,
  }) {
    return createNotificationPayload(
      title: '🎉 Task Completed!',
      body: '$completedBy completed: $taskTitle',
      type: 'task_completed',
      additionalData: {
        'taskId': taskId,
        'taskTitle': taskTitle,
      },
    );
  }

  /// Create loving nudge notification payload
  static Map<String, dynamic> createNudgeNotification({
    required String taskId,
    required String taskTitle,
    required String nudgeMessage,
    required String fromPartner,
  }) {
    return createNotificationPayload(
      title: '💛 Loving Nudge',
      body: '$fromPartner: $nudgeMessage',
      type: 'nudge_received',
      additionalData: {
        'taskId': taskId,
        'taskTitle': taskTitle,
        'message': nudgeMessage,
      },
    );
  }

  /// Dispose of resources
  void dispose() {
    _isInitialized = false;
  }
}
