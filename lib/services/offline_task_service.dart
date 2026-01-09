import 'package:couple_tasks/models/task_model.dart';
import 'package:couple_tasks/services/local_database_service.dart';
import 'package:couple_tasks/services/firestore_service.dart';
import 'package:couple_tasks/services/connectivity_service.dart';

/// Offline-first task service
/// 
/// Provides unified interface for task operations with automatic
/// offline/online handling and sync
class OfflineTaskService {
  final LocalDatabaseService _localDb = LocalDatabaseService();
  final FirestoreService _firestoreService = FirestoreService();
  final ConnectivityService _connectivity = ConnectivityService.instance;

  /// Create task (offline-first)
  Future<void> createTask(TaskModel task) async {
    // Always save locally first
    await _localDb.createTaskLocal(task, syncStatus: 'pending');
    print('✅ Task created locally: ${task.title}');

    // Try to sync to Firestore if online
    if (_connectivity.isOnline) {
      try {
        await _firestoreService.createTask(task);
        await _localDb.markTaskSynced(task.id);
        print('✅ Task synced to Firestore: ${task.title}');
      } catch (e) {
        print('⚠️  Failed to sync task, will retry later: $e');
        // Task remains in local DB with 'pending' status
        await _localDb.addToSyncQueue(
          operation: 'create',
          collection: 'tasks',
          documentId: task.id,
          data: {
            'title': task.title,
            'description': task.description,
            'dueDate': task.dueDate,
            'priority': task.priority,
            'assignedTo': task.assignedTo,
            'assignedToName': task.assignedToName,
            'createdBy': task.createdBy,
            'createdByName': task.createdByName,
            'coupleId': task.coupleId,
            'isCompleted': task.isCompleted,
            'createdAt': task.createdAt,
            'updatedAt': task.updatedAt,
          },
        );
      }
    } else {
      print('📴 Offline: Task queued for sync');
      await _localDb.addToSyncQueue(
        operation: 'create',
        collection: 'tasks',
        documentId: task.id,
        data: {
          'title': task.title,
          'description': task.description,
          'dueDate': task.dueDate,
          'priority': task.priority,
          'assignedTo': task.assignedTo,
          'assignedToName': task.assignedToName,
          'createdBy': task.createdBy,
          'createdByName': task.createdByName,
          'coupleId': task.coupleId,
          'isCompleted': task.isCompleted,
          'createdAt': task.createdAt,
          'updatedAt': task.updatedAt,
        },
      );
    }
  }

  /// Get all tasks (offline-first)
  Future<List<TaskModel>> getTasks(String coupleId) async {
    // Always read from local database first
    final tasks = await _localDb.getTasksLocal(coupleId);
    print('📖 Loaded ${tasks.length} tasks from local database');

    // If online, trigger background sync (don't wait for it)
    if (_connectivity.isOnline) {
      _backgroundSync(coupleId);
    }

    return tasks;
  }

  /// Get task by ID (offline-first)
  Future<TaskModel?> getTaskById(String taskId) async {
    return await _localDb.getTaskByIdLocal(taskId);
  }

  /// Update task (offline-first)
  Future<void> updateTask(TaskModel task) async {
    // Always update locally first
    await _localDb.updateTaskLocal(task, syncStatus: 'pending');
    print('✅ Task updated locally: ${task.title}');

    // Try to sync to Firestore if online
    if (_connectivity.isOnline) {
      try {
        await _firestoreService.updateTask(task);
        await _localDb.markTaskSynced(task.id);
        print('✅ Task synced to Firestore: ${task.title}');
      } catch (e) {
        print('⚠️  Failed to sync task, will retry later: $e');
        await _localDb.addToSyncQueue(
          operation: 'update',
          collection: 'tasks',
          documentId: task.id,
          data: {
            'title': task.title,
            'description': task.description,
            'dueDate': task.dueDate,
            'priority': task.priority,
            'assignedTo': task.assignedTo,
            'assignedToName': task.assignedToName,
            'isCompleted': task.isCompleted,
            'completedAt': task.completedAt,
            'completedBy': task.completedBy,
            'nudgeCount': task.nudgeCount,
            'lastNudgeAt': task.lastNudgeAt,
            'updatedAt': task.updatedAt,
          },
        );
      }
    } else {
      print('📴 Offline: Task update queued for sync');
      await _localDb.addToSyncQueue(
        operation: 'update',
        collection: 'tasks',
        documentId: task.id,
        data: {
          'title': task.title,
          'description': task.description,
          'dueDate': task.dueDate,
          'priority': task.priority,
          'assignedTo': task.assignedTo,
          'assignedToName': task.assignedToName,
          'isCompleted': task.isCompleted,
          'completedAt': task.completedAt,
          'completedBy': task.completedBy,
          'nudgeCount': task.nudgeCount,
          'lastNudgeAt': task.lastNudgeAt,
          'updatedAt': task.updatedAt,
        },
      );
    }
  }

  /// Delete task (offline-first)
  Future<void> deleteTask(String taskId) async {
    // Mark for deletion locally
    await _localDb.deleteTaskLocal(taskId, syncStatus: 'pending_delete');
    print('✅ Task marked for deletion locally');

    // Try to delete from Firestore if online
    if (_connectivity.isOnline) {
      try {
        await _firestoreService.deleteTask(taskId);
        print('✅ Task deleted from Firestore');
      } catch (e) {
        print('⚠️  Failed to delete task, will retry later: $e');
        await _localDb.addToSyncQueue(
          operation: 'delete',
          collection: 'tasks',
          documentId: taskId,
          data: {},
        );
      }
    } else {
      print('📴 Offline: Task deletion queued for sync');
      await _localDb.addToSyncQueue(
        operation: 'delete',
        collection: 'tasks',
        documentId: taskId,
        data: {},
      );
    }
  }

  /// Complete task (offline-first)
  Future<void> completeTask(String taskId, String userId, String userName) async {
    final task = await _localDb.getTaskByIdLocal(taskId);
    if (task == null) {
      print('❌ Task not found: $taskId');
      return;
    }

    final updatedTask = task.copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
      completedBy: userId,
      updatedAt: DateTime.now(),
    );

    await updateTask(updatedTask);
  }

  /// Background sync (non-blocking)
  Future<void> _backgroundSync(String coupleId) async {
    try {
      // This would trigger the sync service in the background
      // For now, just log
      print('🔄 Background sync triggered for couple: $coupleId');
    } catch (e) {
      print('❌ Background sync error: $e');
    }
  }

  /// Get unsynced count
  Future<int> getUnsyncedCount() async {
    return await _localDb.getUnsyncedCount();
  }
}
