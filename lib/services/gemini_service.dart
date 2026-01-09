import 'package:google_generative_ai/google_generative_ai.dart';

/// Service for interacting with Google Gemini AI
/// 
/// This service provides AI-powered features for the Couple Tasks app:
/// - Task suggestions based on couple's patterns
/// - Smart task descriptions and reminders
/// - Relationship communication insights
/// - Personalized nudge messages
/// 
/// Usage:
/// ```dart
/// final geminiService = GeminiService();
/// await geminiService.initialize('YOUR_API_KEY');
/// final suggestion = await geminiService.generateTaskSuggestion(context);
/// ```
class GeminiService {
  GenerativeModel? _model;
  bool _isInitialized = false;

  /// Initialize the Gemini AI service with API key
  /// 
  /// The API key should be stored securely in environment variables
  /// or Firebase Remote Config, never hardcoded in the app.
  /// 
  /// For development, you can get an API key from:
  /// https://makersuite.google.com/app/apikey
  Future<void> initialize(String apiKey) async {
    try {
      _model = GenerativeModel(
        model: 'gemini-2.0-flash-exp',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 1024,
        ),
        safetySettings: [
          SafetySetting(
            HarmCategory.harassment,
            HarmBlockThreshold.medium,
          ),
          SafetySetting(
            HarmCategory.hateSpeech,
            HarmBlockThreshold.medium,
          ),
          SafetySetting(
            HarmCategory.sexuallyExplicit,
            HarmBlockThreshold.medium,
          ),
          SafetySetting(
            HarmCategory.dangerousContent,
            HarmBlockThreshold.medium,
          ),
        ],
      );
      _isInitialized = true;
      print('✅ Gemini AI service initialized successfully');
    } catch (e) {
      print('❌ Error initializing Gemini AI: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  /// Check if the service is initialized
  bool get isInitialized => _isInitialized;

  /// Generate AI-powered task suggestions based on couple's context
  /// 
  /// Example usage:
  /// ```dart
  /// final suggestion = await geminiService.generateTaskSuggestion(
  ///   'We have a dinner date planned this weekend'
  /// );
  /// ```
  Future<String> generateTaskSuggestion(String context) async {
    if (!_isInitialized || _model == null) {
      throw Exception('Gemini AI service not initialized. Call initialize() first.');
    }

    try {
      final prompt = '''
You are a helpful AI assistant for a couple's task management app called "Couple Tasks".
The app helps couples collaborate on tasks with kindness and teamwork.

Context: $context

Based on this context, suggest 3 specific, actionable tasks that would help this couple.
Make the suggestions:
- Practical and achievable
- Considerate of both partners
- Focused on collaboration
- Warm and encouraging in tone

Format each suggestion as a short task title (max 50 characters).
''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Empty response from Gemini AI');
      }

      return response.text!;
    } catch (e) {
      print('❌ Error generating task suggestion: $e');
      rethrow;
    }
  }

  /// Generate a personalized loving nudge message
  /// 
  /// Creates encouraging messages that are warm and supportive,
  /// following the app's philosophy of "Communication with Kindness"
  Future<String> generateLovingNudge({
    required String taskTitle,
    required String partnerName,
    String? taskContext,
  }) async {
    if (!_isInitialized || _model == null) {
      throw Exception('Gemini AI service not initialized. Call initialize() first.');
    }

    try {
      final prompt = '''
You are creating a loving, gentle nudge message for a couple's task app.

Task: "$taskTitle"
Partner's name: $partnerName
${taskContext != null ? 'Context: $taskContext' : ''}

Create a short, sweet message (max 100 characters) that:
- Is warm and encouraging (not nagging)
- Uses loving language
- Motivates without pressure
- Includes an emoji
- Feels personal and caring

Examples of good nudges:
- "💛 Hey love, just a gentle reminder about [task]!"
- "🌸 You've got this! [task] when you have a moment 💕"
- "✨ No rush, but [task] would be amazing!"

Generate ONE nudge message:
''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Empty response from Gemini AI');
      }

      return response.text!.trim();
    } catch (e) {
      print('❌ Error generating loving nudge: $e');
      rethrow;
    }
  }

  /// Enhance task description with AI suggestions
  /// 
  /// Takes a basic task title and generates a more detailed,
  /// helpful description with suggestions for completion
  Future<String> enhanceTaskDescription(String taskTitle) async {
    if (!_isInitialized || _model == null) {
      throw Exception('Gemini AI service not initialized. Call initialize() first.');
    }

    try {
      final prompt = '''
You are helping a couple plan their task: "$taskTitle"

Provide a brief, helpful description (max 150 characters) that:
- Clarifies what needs to be done
- Suggests a practical approach
- Is encouraging and positive
- Uses simple, clear language

Generate the description:
''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Empty response from Gemini AI');
      }

      return response.text!.trim();
    } catch (e) {
      print('❌ Error enhancing task description: $e');
      rethrow;
    }
  }

  /// Generate relationship insights based on task completion patterns
  /// 
  /// Analyzes how the couple works together and provides
  /// positive, constructive insights
  Future<String> generateRelationshipInsight({
    required int tasksCompleted,
    required int tasksShared,
    required int nudgesSent,
  }) async {
    if (!_isInitialized || _model == null) {
      throw Exception('Gemini AI service not initialized. Call initialize() first.');
    }

    try {
      final prompt = '''
You are analyzing a couple's collaboration patterns in their task app.

Statistics:
- Total tasks completed: $tasksCompleted
- Shared tasks: $tasksShared
- Loving nudges sent: $nudgesSent

Generate a warm, positive insight (max 200 characters) about their teamwork that:
- Celebrates their collaboration
- Is encouraging and uplifting
- Focuses on their strengths
- Feels personal and meaningful
- Includes an emoji

Generate the insight:
''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Empty response from Gemini AI');
      }

      return response.text!.trim();
    } catch (e) {
      print('❌ Error generating relationship insight: $e');
      rethrow;
    }
  }

  /// Generate smart reminder text based on task urgency and context
  Future<String> generateSmartReminder({
    required String taskTitle,
    required DateTime dueDate,
    bool isOverdue = false,
  }) async {
    if (!_isInitialized || _model == null) {
      throw Exception('Gemini AI service not initialized. Call initialize() first.');
    }

    try {
      final now = DateTime.now();
      final daysUntilDue = dueDate.difference(now).inDays;
      
      final prompt = '''
Create a smart reminder message for a task.

Task: "$taskTitle"
Due date: ${dueDate.toString().split(' ')[0]}
Days until due: $daysUntilDue
${isOverdue ? 'Status: OVERDUE' : 'Status: Upcoming'}

Generate a brief reminder (max 120 characters) that:
- Is appropriate for the urgency level
- Is encouraging, not stressful
- Includes a relevant emoji
- Feels supportive

Generate the reminder:
''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Empty response from Gemini AI');
      }

      return response.text!.trim();
    } catch (e) {
      print('❌ Error generating smart reminder: $e');
      rethrow;
    }
  }

  /// Chat with Gemini AI for general assistance
  /// 
  /// Allows free-form conversation for help with tasks,
  /// relationship advice, or planning
  Future<String> chat(String message, {List<Content>? history}) async {
    if (!_isInitialized || _model == null) {
      throw Exception('Gemini AI service not initialized. Call initialize() first.');
    }

    try {
      final chat = _model!.startChat(history: history ?? []);
      final response = await chat.sendMessage(Content.text(message));

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Empty response from Gemini AI');
      }

      return response.text!;
    } catch (e) {
      print('❌ Error in chat: $e');
      rethrow;
    }
  }

  /// Dispose of resources
  void dispose() {
    _model = null;
    _isInitialized = false;
  }
}
