/// Application configuration
/// Contains API keys and environment-specific settings
class AppConfig {
  // Gemini AI Configuration
  static const String geminiApiKey = 'AIzaSyAeLRsn6RmIW8cJ6RBQoySgcLN73P7GH9U';
  
  // App Configuration
  static const String appName = 'Couple Tasks';
  static const String appVersion = '1.0.0';
  
  // Feature Flags
  static const bool enableAIFeatures = true;
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = true;
  
  // Subscription Configuration
  static const String monthlyProductId = 'couple_tasks_monthly';
  static const String annualProductId = 'couple_tasks_annual';
  static const double monthlyPrice = 4.99;
  static const double annualPrice = 49.99;
  
  // AI Model Configuration
  static const String geminiModel = 'gemini-2.0-flash-exp';
  static const int maxTokens = 1000;
  static const double temperature = 0.7;
  
  // Invite Configuration
  static const int inviteCodeLength = 8;
  static const int inviteExpirationDays = 7;
  
  // Task Configuration
  static const int maxTasksPerCouple = 100;
  static const int maxNudgesPerTask = 10;
  
  // Offline Configuration
  static const int syncRetryAttempts = 3;
  static const int syncRetryDelaySeconds = 5;
  
  /// Check if AI features are enabled and API key is configured
  static bool get isAIEnabled => 
    enableAIFeatures && geminiApiKey.isNotEmpty;
  
  /// Check if subscription features are enabled
  static bool get isSubscriptionEnabled => 
    monthlyProductId.isNotEmpty && annualProductId.isNotEmpty;
}
