import 'package:firebase_analytics/firebase_analytics.dart';

/// Service for tracking user behavior and app usage with Firebase Analytics
/// 
/// This service provides comprehensive analytics for:
/// - User engagement and retention
/// - Task creation and completion patterns
/// - Couple collaboration metrics
/// - Feature usage tracking
/// - User journey analysis
/// 
/// Usage:
/// ```dart
/// final analytics = AnalyticsService();
/// await analytics.logTaskCreated(taskId: 'task123', assignedTo: 'both');
/// ```
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  bool _isInitialized = false;

  /// Get the analytics instance
  FirebaseAnalytics get analytics => _analytics;

  /// Get the analytics observer for navigation tracking
  FirebaseAnalyticsObserver get observer => 
      FirebaseAnalyticsObserver(analytics: _analytics);

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the analytics service
  Future<void> initialize() async {
    try {
      print('📊 Initializing analytics service...');
      
      // Set analytics collection enabled
      await _analytics.setAnalyticsCollectionEnabled(true);
      
      _isInitialized = true;
      print('✅ Analytics service initialized successfully');
    } catch (e) {
      print('❌ Error initializing analytics: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  /// Set user properties for segmentation
  Future<void> setUserProperties({
    required String userId,
    String? coupleId,
    bool? isPremium,
  }) async {
    try {
      await _analytics.setUserId(id: userId);
      
      if (coupleId != null) {
        await _analytics.setUserProperty(
          name: 'couple_id',
          value: coupleId,
        );
      }
      
      if (isPremium != null) {
        await _analytics.setUserProperty(
          name: 'is_premium',
          value: isPremium.toString(),
        );
      }
      
      print('✅ User properties set for: $userId');
    } catch (e) {
      print('❌ Error setting user properties: $e');
    }
  }

  // ==================== AUTHENTICATION EVENTS ====================

  /// Log user sign up event
  Future<void> logSignUp({required String method}) async {
    try {
      await _analytics.logSignUp(signUpMethod: method);
      print('📊 Logged: sign_up (method: $method)');
    } catch (e) {
      print('❌ Error logging sign_up: $e');
    }
  }

  /// Log user login event
  Future<void> logLogin({required String method}) async {
    try {
      await _analytics.logLogin(loginMethod: method);
      print('📊 Logged: login (method: $method)');
    } catch (e) {
      print('❌ Error logging login: $e');
    }
  }

  // ==================== ONBOARDING EVENTS ====================

  /// Log onboarding started
  Future<void> logOnboardingStarted() async {
    try {
      await _analytics.logEvent(
        name: 'onboarding_started',
        parameters: {
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      print('📊 Logged: onboarding_started');
    } catch (e) {
      print('❌ Error logging onboarding_started: $e');
    }
  }

  /// Log onboarding completed
  Future<void> logOnboardingCompleted() async {
    try {
      await _analytics.logEvent(
        name: 'onboarding_completed',
        parameters: {
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      print('📊 Logged: onboarding_completed');
    } catch (e) {
      print('❌ Error logging onboarding_completed: $e');
    }
  }

  /// Log couple setup completed
  Future<void> logCoupleSetupCompleted({
    required String coupleId,
    required bool isCreator,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'couple_setup_completed',
        parameters: {
          'couple_id': coupleId,
          'is_creator': isCreator,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      print('📊 Logged: couple_setup_completed');
    } catch (e) {
      print('❌ Error logging couple_setup_completed: $e');
    }
  }

  // ==================== TASK EVENTS ====================

  /// Log task created
  Future<void> logTaskCreated({
    required String taskId,
    required String assignedTo, // 'me', 'partner', 'both'
    bool hasDueDate = false,
    bool hasDescription = false,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'task_created',
        parameters: {
          'task_id': taskId,
          'assigned_to': assignedTo,
          'has_due_date': hasDueDate,
          'has_description': hasDescription,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      print('📊 Logged: task_created (assigned_to: $assignedTo)');
    } catch (e) {
      print('❌ Error logging task_created: $e');
    }
  }

  /// Log task completed
  Future<void> logTaskCompleted({
    required String taskId,
    required String assignedTo,
    required int daysToComplete,
    bool wasOverdue = false,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'task_completed',
        parameters: {
          'task_id': taskId,
          'assigned_to': assignedTo,
          'days_to_complete': daysToComplete,
          'was_overdue': wasOverdue,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      print('📊 Logged: task_completed (days: $daysToComplete)');
    } catch (e) {
      print('❌ Error logging task_completed: $e');
    }
  }

  /// Log task deleted
  Future<void> logTaskDeleted({
    required String taskId,
    required bool wasCompleted,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'task_deleted',
        parameters: {
          'task_id': taskId,
          'was_completed': wasCompleted,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      print('📊 Logged: task_deleted');
    } catch (e) {
      print('❌ Error logging task_deleted: $e');
    }
  }

  // ==================== NUDGE EVENTS ====================

  /// Log loving nudge sent
  Future<void> logNudgeSent({
    required String taskId,
    required String nudgeType, // 'preset' or 'custom'
    String? message,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'nudge_sent',
        parameters: {
          'task_id': taskId,
          'nudge_type': nudgeType,
          'has_custom_message': message != null,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      print('📊 Logged: nudge_sent (type: $nudgeType)');
    } catch (e) {
      print('❌ Error logging nudge_sent: $e');
    }
  }

  /// Log nudge received
  Future<void> logNudgeReceived({
    required String taskId,
    required String fromPartner,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'nudge_received',
        parameters: {
          'task_id': taskId,
          'from_partner': fromPartner,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      print('📊 Logged: nudge_received');
    } catch (e) {
      print('❌ Error logging nudge_received: $e');
    }
  }

  // ==================== COLLABORATION METRICS ====================

  /// Log shared task interaction
  Future<void> logSharedTaskInteraction({
    required String taskId,
    required String interactionType, // 'view', 'edit', 'complete'
  }) async {
    try {
      await _analytics.logEvent(
        name: 'shared_task_interaction',
        parameters: {
          'task_id': taskId,
          'interaction_type': interactionType,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      print('📊 Logged: shared_task_interaction ($interactionType)');
    } catch (e) {
      print('❌ Error logging shared_task_interaction: $e');
    }
  }

  /// Log collaboration milestone reached
  Future<void> logCollaborationMilestone({
    required String milestoneType, // 'first_task', '10_tasks', '50_tasks', etc.
    required int totalTasks,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'collaboration_milestone',
        parameters: {
          'milestone_type': milestoneType,
          'total_tasks': totalTasks,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      print('📊 Logged: collaboration_milestone ($milestoneType)');
    } catch (e) {
      print('❌ Error logging collaboration_milestone: $e');
    }
  }

  // ==================== AI FEATURE EVENTS ====================

  /// Log AI feature used
  Future<void> logAIFeatureUsed({
    required String featureType, // 'task_suggestion', 'nudge_generation', etc.
    bool wasSuccessful = true,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'ai_feature_used',
        parameters: {
          'feature_type': featureType,
          'was_successful': wasSuccessful,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      print('📊 Logged: ai_feature_used ($featureType)');
    } catch (e) {
      print('❌ Error logging ai_feature_used: $e');
    }
  }

  /// Log AI suggestion accepted
  Future<void> logAISuggestionAccepted({
    required String suggestionType,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'ai_suggestion_accepted',
        parameters: {
          'suggestion_type': suggestionType,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      print('📊 Logged: ai_suggestion_accepted');
    } catch (e) {
      print('❌ Error logging ai_suggestion_accepted: $e');
    }
  }

  // ==================== SCREEN VIEW EVENTS ====================

  /// Log screen view
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
      print('📊 Logged: screen_view ($screenName)');
    } catch (e) {
      print('❌ Error logging screen_view: $e');
    }
  }

  // ==================== ENGAGEMENT EVENTS ====================

  /// Log app opened
  Future<void> logAppOpened({String? source}) async {
    try {
      await _analytics.logEvent(
        name: 'app_opened',
        parameters: {
          'source': source ?? 'direct',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      print('📊 Logged: app_opened');
    } catch (e) {
      print('❌ Error logging app_opened: $e');
    }
  }

  /// Log feature discovery
  Future<void> logFeatureDiscovery({
    required String featureName,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'feature_discovery',
        parameters: {
          'feature_name': featureName,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      print('📊 Logged: feature_discovery ($featureName)');
    } catch (e) {
      print('❌ Error logging feature_discovery: $e');
    }
  }

  /// Log user retention (daily active)
  Future<void> logDailyActive() async {
    try {
      await _analytics.logEvent(
        name: 'daily_active',
        parameters: {
          'date': DateTime.now().toIso8601String().split('T')[0],
        },
      );
      print('📊 Logged: daily_active');
    } catch (e) {
      print('❌ Error logging daily_active: $e');
    }
  }

  // ==================== ERROR TRACKING ====================

  /// Log error event
  Future<void> logError({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'app_error',
        parameters: {
          'error_type': errorType,
          'error_message': errorMessage,
          'has_stack_trace': stackTrace != null,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      print('📊 Logged: app_error ($errorType)');
    } catch (e) {
      print('❌ Error logging app_error: $e');
    }
  }

  // ==================== CUSTOM EVENTS ====================

  /// Log custom event with parameters
  Future<void> logCustomEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: eventName,
        parameters: parameters,
      );
      print('📊 Logged: $eventName');
    } catch (e) {
      print('❌ Error logging $eventName: $e');
    }
  }

  /// Dispose of resources
  void dispose() {
    _isInitialized = false;
  }
}
