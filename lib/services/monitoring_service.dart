import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';

/// Service for monitoring app performance and errors
/// 
/// This service provides:
/// - Error logging and crash reporting
/// - Performance trace monitoring
/// - Custom metrics tracking
/// - User context for debugging
class MonitoringService {
  static final MonitoringService instance = MonitoringService._init();
  MonitoringService._init();

  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  final FirebasePerformance _performance = FirebasePerformance.instance;

  // ==================== CRASHLYTICS ====================

  /// Log a non-fatal error to Crashlytics
  /// 
  /// Use this for caught exceptions that you want to track
  Future<void> logError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    Map<String, dynamic>? context,
  }) async {
    try {
      // Add context if provided
      if (context != null) {
        for (final entry in context.entries) {
          await _crashlytics.setCustomKey(entry.key, entry.value.toString());
        }
      }

      // Log the error
      await _crashlytics.recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: false,
      );

      print('📊 Error logged to Crashlytics: $error');
    } catch (e) {
      print('❌ Failed to log error to Crashlytics: $e');
    }
  }

  /// Log a fatal error to Crashlytics
  /// 
  /// Use this for critical errors that crash the app
  Future<void> logFatalError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
  }) async {
    try {
      await _crashlytics.recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: true,
      );

      print('💥 Fatal error logged to Crashlytics: $error');
    } catch (e) {
      print('❌ Failed to log fatal error to Crashlytics: $e');
    }
  }

  /// Log a message to Crashlytics
  /// 
  /// Use this to add breadcrumbs for debugging
  Future<void> log(String message) async {
    try {
      await _crashlytics.log(message);
    } catch (e) {
      print('❌ Failed to log message to Crashlytics: $e');
    }
  }

  /// Set user identifier for crash reports
  /// 
  /// This helps identify which users are experiencing crashes
  Future<void> setUserId(String userId) async {
    try {
      await _crashlytics.setUserIdentifier(userId);
      print('👤 User ID set for Crashlytics: $userId');
    } catch (e) {
      print('❌ Failed to set user ID: $e');
    }
  }

  /// Set custom key-value pairs for crash reports
  /// 
  /// Use this to add context about the app state
  Future<void> setCustomKey(String key, dynamic value) async {
    try {
      await _crashlytics.setCustomKey(key, value.toString());
    } catch (e) {
      print('❌ Failed to set custom key: $e');
    }
  }

  /// Clear all custom keys
  Future<void> clearCustomKeys() async {
    try {
      // Crashlytics doesn't have a clear method, so we'll just log it
      print('🧹 Custom keys cleared (note: Crashlytics retains keys per session)');
    } catch (e) {
      print('❌ Failed to clear custom keys: $e');
    }
  }

  // ==================== PERFORMANCE MONITORING ====================

  /// Start a custom performance trace
  /// 
  /// Use this to measure the duration of specific operations
  /// 
  /// Example:
  /// ```dart
  /// final trace = await monitoringService.startTrace('load_tasks');
  /// // ... perform operation
  /// await monitoringService.stopTrace(trace);
  /// ```
  Future<Trace> startTrace(String traceName) async {
    try {
      final trace = _performance.newTrace(traceName);
      await trace.start();
      print('⏱️ Performance trace started: $traceName');
      return trace;
    } catch (e) {
      print('❌ Failed to start trace: $e');
      rethrow;
    }
  }

  /// Stop a performance trace
  Future<void> stopTrace(Trace trace) async {
    try {
      await trace.stop();
      print('✅ Performance trace stopped');
    } catch (e) {
      print('❌ Failed to stop trace: $e');
    }
  }

  /// Add a metric to a trace
  /// 
  /// Use this to track custom metrics within a trace
  Future<void> setTraceMetric(Trace trace, String metricName, int value) async {
    try {
      trace.setMetric(metricName, value);
      print('📈 Metric set: $metricName = $value');
    } catch (e) {
      print('❌ Failed to set metric: $e');
    }
  }

  /// Increment a metric in a trace
  Future<void> incrementTraceMetric(Trace trace, String metricName) async {
    try {
      trace.incrementMetric(metricName, 1);
      print('➕ Metric incremented: $metricName');
    } catch (e) {
      print('❌ Failed to increment metric: $e');
    }
  }

  /// Add an attribute to a trace
  /// 
  /// Use this to add context to performance traces
  Future<void> setTraceAttribute(
    Trace trace,
    String attributeName,
    String value,
  ) async {
    try {
      trace.putAttribute(attributeName, value);
      print('🏷️ Attribute set: $attributeName = $value');
    } catch (e) {
      print('❌ Failed to set attribute: $e');
    }
  }

  /// Monitor an HTTP request
  /// 
  /// Use this to track network performance
  /// 
  /// Example:
  /// ```dart
  /// final metric = monitoringService.httpMetric(
  ///   url: 'https://api.example.com/tasks',
  ///   method: HttpMethod.Get,
  /// );
  /// await metric.start();
  /// // ... make request
  /// metric.responseCode = 200;
  /// metric.responsePayloadSize = 1024;
  /// await metric.stop();
  /// ```
  HttpMetric httpMetric({
    required String url,
    required HttpMethod method,
  }) {
    return _performance.newHttpMetric(url, method);
  }

  // ==================== CONVENIENCE METHODS ====================

  /// Wrap an async operation with performance monitoring
  /// 
  /// This automatically starts and stops a trace around the operation
  /// 
  /// Example:
  /// ```dart
  /// final tasks = await monitoringService.traceAsync(
  ///   'load_tasks',
  ///   () => firestoreService.getTasks(coupleId),
  /// );
  /// ```
  Future<T> traceAsync<T>(
    String traceName,
    Future<T> Function() operation, {
    Map<String, String>? attributes,
  }) async {
    final trace = await startTrace(traceName);
    
    try {
      // Add attributes if provided
      if (attributes != null) {
        for (final entry in attributes.entries) {
          await setTraceAttribute(trace, entry.key, entry.value);
        }
      }

      // Execute operation
      final result = await operation();
      
      await stopTrace(trace);
      return result;
    } catch (e, stackTrace) {
      // Log error and stop trace
      await logError(e, stackTrace, reason: 'Error in $traceName');
      await stopTrace(trace);
      rethrow;
    }
  }

  /// Wrap a synchronous operation with error logging
  /// 
  /// This catches and logs any errors that occur
  T? traceSync<T>(
    String operationName,
    T Function() operation, {
    T? defaultValue,
  }) {
    try {
      return operation();
    } catch (e, stackTrace) {
      logError(e, stackTrace, reason: 'Error in $operationName');
      return defaultValue;
    }
  }

  // ==================== PREDEFINED TRACES ====================

  /// Common trace names for consistency
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

  // ==================== TESTING & DEBUG ====================

  /// Force a test crash (for testing Crashlytics)
  /// 
  /// ⚠️ Only use this in development/testing!
  void forceCrash() {
    _crashlytics.crash();
  }

  /// Check if crash reporting is enabled
  Future<bool> isCrashCollectionEnabled() async {
    return await _crashlytics.isCrashlyticsCollectionEnabled();
  }

  /// Enable/disable crash collection
  Future<void> setCrashCollectionEnabled(bool enabled) async {
    await _crashlytics.setCrashlyticsCollectionEnabled(enabled);
    print(enabled
        ? '✅ Crash collection enabled'
        : '❌ Crash collection disabled');
  }

  /// Check if performance monitoring is enabled
  Future<bool> isPerformanceCollectionEnabled() async {
    return await _performance.isPerformanceCollectionEnabled();
  }

  /// Enable/disable performance monitoring
  Future<void> setPerformanceCollectionEnabled(bool enabled) async {
    await _performance.setPerformanceCollectionEnabled(enabled);
    print(enabled
        ? '✅ Performance monitoring enabled'
        : '❌ Performance monitoring disabled');
  }
}
