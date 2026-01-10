import 'package:flutter_test/flutter_test.dart';
import 'package:couple_tasks/services/gemini_service.dart';
import 'package:couple_tasks/config/app_config.dart';

/// Test file for Gemini AI integration
/// 
/// Run with: flutter test test/gemini_test.dart
void main() {
  group('Gemini AI Integration Tests', () {
    late GeminiService geminiService;

    setUp(() {
      geminiService = GeminiService();
    });

    test('API key is configured', () {
      expect(AppConfig.geminiApiKey, isNotEmpty);
      expect(AppConfig.geminiApiKey.length, greaterThan(20));
    });

    test('AI features are enabled', () {
      expect(AppConfig.isAIEnabled, isTrue);
    });

    test('Gemini service can be initialized', () async {
      expect(() async => await geminiService.initialize(), returnsNormally);
    });

    test('Task suggestion generation works', () async {
      await geminiService.initialize();
      
      final suggestion = await geminiService.generateTaskSuggestion(
        'We are a couple trying to organize our household chores',
      );
      
      expect(suggestion, isNotEmpty);
      expect(suggestion.length, greaterThan(10));
    });

    test('Loving nudge generation works', () async {
      await geminiService.initialize();
      
      final nudge = await geminiService.generateLovingNudge(
        taskTitle: 'Do the dishes',
        partnerName: 'Alex',
      );
      
      expect(nudge, isNotEmpty);
      expect(nudge.length, greaterThan(10));
    });

    test('Enhanced task description works', () async {
      await geminiService.initialize();
      
      final enhanced = await geminiService.enhanceTaskDescription(
        title: 'Grocery shopping',
        currentDescription: 'Buy food',
      );
      
      expect(enhanced, isNotEmpty);
      expect(enhanced.length, greaterThan(10));
    });

    test('Relationship insights generation works', () async {
      await geminiService.initialize();
      
      final insights = await geminiService.generateRelationshipInsights(
        completedTasks: 10,
        totalTasks: 15,
        nudgesSent: 5,
      );
      
      expect(insights, isNotEmpty);
      expect(insights.length, greaterThan(10));
    });

    test('Chat functionality works', () async {
      await geminiService.initialize();
      
      final response = await geminiService.chat(
        'How can we better organize our tasks as a couple?',
      );
      
      expect(response, isNotEmpty);
      expect(response.length, greaterThan(10));
    });
  });
}
