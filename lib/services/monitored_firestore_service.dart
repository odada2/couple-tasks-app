import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:couple_tasks/models/task_model.dart';
import 'package:couple_tasks/models/user_model.dart';
import 'package:couple_tasks/models/couple_model.dart';
import 'package:couple_tasks/services/monitoring_service.dart';

/// Example of integrating monitoring into Firestore operations
/// 
/// This demonstrates how to add performance traces and error logging
/// to database operations. Apply this pattern to all services.
class MonitoredFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MonitoringService _monitoring = MonitoringService.instance;

  // ==================== TASKS ====================

  /// Get all tasks for a couple (with monitoring)
  Future<List<TaskModel>> getTasks(String coupleId) async {
    return await _monitoring.traceAsync(
      MonitoringService.traceLoadTasks,
      () async {
        try {
          final snapshot = await _firestore
              .collection('tasks')
              .where('coupleId', isEqualTo: coupleId)
              .orderBy('createdAt', descending: true)
              .get();

          final tasks = snapshot.docs
              .map((doc) => TaskModel.fromMap(doc.data(), doc.id))
              .toList();

          // Log successful load
          await _monitoring.log('Loaded ${tasks.length} tasks for couple $coupleId');

          return tasks;
        } catch (e, stackTrace) {
          // Error is automatically logged by traceAsync
          await _monitoring.logError(
            e,
            stackTrace,
            reason: 'Failed to load tasks',
            context: {'coupleId': coupleId},
          );
          rethrow;
        }
      },
      attributes: {
        'couple_id': coupleId,
        'operation': 'get_tasks',
      },
    );
  }

  /// Create a new task (with monitoring)
  Future<String> createTask(TaskModel task) async {
    return await _monitoring.traceAsync(
      MonitoringService.traceCreateTask,
      () async {
        try {
          final docRef = await _firestore.collection('tasks').add(task.toMap());

          // Log successful creation
          await _monitoring.log('Task created: ${task.title}');
          await _monitoring.setCustomKey('last_task_created', task.title);

          return docRef.id;
        } catch (e, stackTrace) {
          await _monitoring.logError(
            e,
            stackTrace,
            reason: 'Failed to create task',
            context: {
              'task_title': task.title,
              'couple_id': task.coupleId,
            },
          );
          rethrow;
        }
      },
      attributes: {
        'couple_id': task.coupleId,
        'assigned_to': task.assignedTo,
        'operation': 'create_task',
      },
    );
  }

  /// Update a task (with monitoring)
  Future<void> updateTask(String taskId, Map<String, dynamic> updates) async {
    return await _monitoring.traceAsync(
      MonitoringService.traceUpdateTask,
      () async {
        try {
          await _firestore.collection('tasks').doc(taskId).update(updates);

          // Log successful update
          await _monitoring.log('Task updated: $taskId');
        } catch (e, stackTrace) {
          await _monitoring.logError(
            e,
            stackTrace,
            reason: 'Failed to update task',
            context: {
              'task_id': taskId,
              'updates': updates.keys.join(', '),
            },
          );
          rethrow;
        }
      },
      attributes: {
        'task_id': taskId,
        'operation': 'update_task',
      },
    );
  }

  /// Delete a task (with monitoring)
  Future<void> deleteTask(String taskId) async {
    return await _monitoring.traceAsync(
      MonitoringService.traceDeleteTask,
      () async {
        try {
          await _firestore.collection('tasks').doc(taskId).delete();

          // Log successful deletion
          await _monitoring.log('Task deleted: $taskId');
        } catch (e, stackTrace) {
          await _monitoring.logError(
            e,
            stackTrace,
            reason: 'Failed to delete task',
            context: {'task_id': taskId},
          );
          rethrow;
        }
      },
      attributes: {
        'task_id': taskId,
        'operation': 'delete_task',
      },
    );
  }

  // ==================== USERS ====================

  /// Get user data (with monitoring)
  Future<UserModel?> getUser(String userId) async {
    return await _monitoring.traceAsync(
      'load_user',
      () async {
        try {
          final doc = await _firestore.collection('users').doc(userId).get();

          if (!doc.exists) {
            await _monitoring.log('User not found: $userId');
            return null;
          }

          final user = UserModel.fromMap(doc.data()!, doc.id);
          
          // Set user context for crash reports
          await _monitoring.setUserId(userId);
          await _monitoring.setCustomKey('user_email', user.email);
          await _monitoring.setCustomKey('has_partner', user.coupleId != null);

          return user;
        } catch (e, stackTrace) {
          await _monitoring.logError(
            e,
            stackTrace,
            reason: 'Failed to load user',
            context: {'user_id': userId},
          );
          rethrow;
        }
      },
      attributes: {
        'user_id': userId,
        'operation': 'get_user',
      },
    );
  }

  // ==================== COUPLES ====================

  /// Get couple data (with monitoring)
  Future<CoupleModel?> getCouple(String coupleId) async {
    return await _monitoring.traceAsync(
      'load_couple',
      () async {
        try {
          final doc = await _firestore.collection('couples').doc(coupleId).get();

          if (!doc.exists) {
            await _monitoring.log('Couple not found: $coupleId');
            return null;
          }

          final couple = CoupleModel.fromMap(doc.data()!, doc.id);
          
          // Set couple context for crash reports
          await _monitoring.setCustomKey('couple_id', coupleId);
          await _monitoring.setCustomKey('couple_created_at', couple.createdAt.toIso8601String());

          return couple;
        } catch (e, stackTrace) {
          await _monitoring.logError(
            e,
            stackTrace,
            reason: 'Failed to load couple',
            context: {'couple_id': coupleId},
          );
          rethrow;
        }
      },
      attributes: {
        'couple_id': coupleId,
        'operation': 'get_couple',
      },
    );
  }

  // ==================== EXAMPLE: HTTP MONITORING ====================

  /// Example of monitoring an HTTP request
  /// 
  /// This shows how to track network performance
  Future<void> exampleHttpMonitoring() async {
    final metric = _monitoring.httpMetric(
      url: 'https://api.example.com/tasks',
      method: HttpMethod.Get,
    );

    try {
      await metric.start();

      // Make your HTTP request here
      // final response = await http.get(...);

      // Set response details
      metric.responseCode = 200;
      metric.responsePayloadSize = 1024; // bytes
      metric.requestPayloadSize = 256; // bytes

      await metric.stop();
    } catch (e, stackTrace) {
      await _monitoring.logError(e, stackTrace, reason: 'HTTP request failed');
      await metric.stop();
      rethrow;
    }
  }
}
