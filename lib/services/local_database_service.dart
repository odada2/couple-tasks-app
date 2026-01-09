import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:couple_tasks/services/database_helper.dart';
import 'package:couple_tasks/models/task_model.dart';
import 'package:couple_tasks/models/user_model.dart';
import 'package:couple_tasks/models/couple_model.dart';
import 'package:couple_tasks/models/nudge_model.dart';
import 'package:couple_tasks/models/invite_model.dart';

/// Local database service for offline-first data operations
/// 
/// Provides CRUD operations for all app data with SQLite persistence
class LocalDatabaseService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ==================== TASKS ====================

  /// Create task locally
  Future<void> createTaskLocal(TaskModel task, {String syncStatus = 'pending'}) async {
    final db = await _dbHelper.database;
    
    await db.insert(
      'tasks',
      {
        'id': task.id,
        'title': task.title,
        'description': task.description,
        'dueDate': task.dueDate?.millisecondsSinceEpoch,
        'priority': task.priority,
        'assignedTo': task.assignedTo,
        'assignedToName': task.assignedToName,
        'createdBy': task.createdBy,
        'createdByName': task.createdByName,
        'coupleId': task.coupleId,
        'isCompleted': task.isCompleted ? 1 : 0,
        'completedAt': task.completedAt?.millisecondsSinceEpoch,
        'completedBy': task.completedBy,
        'nudgeCount': task.nudgeCount,
        'lastNudgeAt': task.lastNudgeAt?.millisecondsSinceEpoch,
        'createdAt': task.createdAt.millisecondsSinceEpoch,
        'updatedAt': task.updatedAt.millisecondsSinceEpoch,
        'syncStatus': syncStatus,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print('✅ Task created locally: ${task.title}');
  }

  /// Get all tasks for a couple
  Future<List<TaskModel>> getTasksLocal(String coupleId) async {
    final db = await _dbHelper.database;
    
    final maps = await db.query(
      'tasks',
      where: 'coupleId = ?',
      whereArgs: [coupleId],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => _taskFromMap(map)).toList();
  }

  /// Get task by ID
  Future<TaskModel?> getTaskByIdLocal(String taskId) async {
    final db = await _dbHelper.database;
    
    final maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [taskId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return _taskFromMap(maps.first);
  }

  /// Update task locally
  Future<void> updateTaskLocal(TaskModel task, {String syncStatus = 'pending'}) async {
    final db = await _dbHelper.database;
    
    await db.update(
      'tasks',
      {
        'title': task.title,
        'description': task.description,
        'dueDate': task.dueDate?.millisecondsSinceEpoch,
        'priority': task.priority,
        'assignedTo': task.assignedTo,
        'assignedToName': task.assignedToName,
        'isCompleted': task.isCompleted ? 1 : 0,
        'completedAt': task.completedAt?.millisecondsSinceEpoch,
        'completedBy': task.completedBy,
        'nudgeCount': task.nudgeCount,
        'lastNudgeAt': task.lastNudgeAt?.millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
        'syncStatus': syncStatus,
      },
      where: 'id = ?',
      whereArgs: [task.id],
    );

    print('✅ Task updated locally: ${task.title}');
  }

  /// Delete task locally
  Future<void> deleteTaskLocal(String taskId, {String syncStatus = 'pending_delete'}) async {
    final db = await _dbHelper.database;
    
    // Mark as pending delete instead of actually deleting
    await db.update(
      'tasks',
      {'syncStatus': syncStatus},
      where: 'id = ?',
      whereArgs: [taskId],
    );

    print('✅ Task marked for deletion: $taskId');
  }

  /// Get unsynced tasks
  Future<List<TaskModel>> getUnsyncedTasks() async {
    final db = await _dbHelper.database;
    
    final maps = await db.query(
      'tasks',
      where: 'syncStatus != ?',
      whereArgs: ['synced'],
    );

    return maps.map((map) => _taskFromMap(map)).toList();
  }

  /// Mark task as synced
  Future<void> markTaskSynced(String taskId) async {
    final db = await _dbHelper.database;
    
    await db.update(
      'tasks',
      {'syncStatus': 'synced'},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  /// Convert map to TaskModel
  TaskModel _taskFromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dueDate: map['dueDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'])
          : null,
      priority: map['priority'],
      assignedTo: map['assignedTo'],
      assignedToName: map['assignedToName'],
      createdBy: map['createdBy'],
      createdByName: map['createdByName'],
      coupleId: map['coupleId'],
      isCompleted: map['isCompleted'] == 1,
      completedAt: map['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completedAt'])
          : null,
      completedBy: map['completedBy'],
      nudgeCount: map['nudgeCount'] ?? 0,
      lastNudgeAt: map['lastNudgeAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastNudgeAt'])
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  // ==================== USERS ====================

  /// Save user locally
  Future<void> saveUserLocal(UserModel user, {String syncStatus = 'synced'}) async {
    final db = await _dbHelper.database;
    
    await db.insert(
      'users',
      {
        'id': user.id,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'coupleId': user.coupleId,
        'partnerId': user.partnerId,
        'partnerName': user.partnerName,
        'partnerEmail': user.partnerEmail,
        'createdAt': user.createdAt.millisecondsSinceEpoch,
        'updatedAt': user.updatedAt.millisecondsSinceEpoch,
        'syncStatus': syncStatus,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print('✅ User saved locally: ${user.displayName}');
  }

  /// Get user by ID
  Future<UserModel?> getUserLocal(String userId) async {
    final db = await _dbHelper.database;
    
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    
    final map = maps.first;
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String?,
      photoURL: map['photoURL'] as String?,
      coupleId: map['coupleId'] as String?,
      partnerId: map['partnerId'] as String?,
      partnerName: map['partnerName'] as String?,
      partnerEmail: map['partnerEmail'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }

  // ==================== COUPLES ====================

  /// Save couple locally
  Future<void> saveCoupleLocal(CoupleModel couple, {String syncStatus = 'synced'}) async {
    final db = await _dbHelper.database;
    
    await db.insert(
      'couples',
      {
        'id': couple.id,
        'user1Id': couple.user1Id,
        'user1Name': couple.user1Name,
        'user1Email': couple.user1Email,
        'user2Id': couple.user2Id,
        'user2Name': couple.user2Name,
        'user2Email': couple.user2Email,
        'tasksCompleted': couple.tasksCompleted,
        'nudgesSent': couple.nudgesSent,
        'createdAt': couple.createdAt.millisecondsSinceEpoch,
        'updatedAt': couple.updatedAt.millisecondsSinceEpoch,
        'syncStatus': syncStatus,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print('✅ Couple saved locally: ${couple.id}');
  }

  /// Get couple by ID
  Future<CoupleModel?> getCoupleLocal(String coupleId) async {
    final db = await _dbHelper.database;
    
    final maps = await db.query(
      'couples',
      where: 'id = ?',
      whereArgs: [coupleId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    
    final map = maps.first;
    return CoupleModel(
      id: map['id'] as String,
      user1Id: map['user1Id'] as String,
      user1Name: map['user1Name'] as String,
      user1Email: map['user1Email'] as String,
      user2Id: map['user2Id'] as String,
      user2Name: map['user2Name'] as String,
      user2Email: map['user2Email'] as String,
      tasksCompleted: map['tasksCompleted'] as int,
      nudgesSent: map['nudgesSent'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }

  // ==================== NUDGES ====================

  /// Create nudge locally
  Future<void> createNudgeLocal(NudgeModel nudge, {String syncStatus = 'pending'}) async {
    final db = await _dbHelper.database;
    
    await db.insert(
      'nudges',
      {
        'id': nudge.id,
        'taskId': nudge.taskId,
        'fromUserId': nudge.fromUserId,
        'fromUserName': nudge.fromUserName,
        'toUserId': nudge.toUserId,
        'toUserName': nudge.toUserName,
        'message': nudge.message,
        'emoji': nudge.emoji,
        'createdAt': nudge.createdAt.millisecondsSinceEpoch,
        'syncStatus': syncStatus,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print('✅ Nudge created locally');
  }

  /// Get nudges for a task
  Future<List<NudgeModel>> getNudgesForTaskLocal(String taskId) async {
    final db = await _dbHelper.database;
    
    final maps = await db.query(
      'nudges',
      where: 'taskId = ?',
      whereArgs: [taskId],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => NudgeModel(
      id: map['id'] as String,
      taskId: map['taskId'] as String,
      fromUserId: map['fromUserId'] as String,
      fromUserName: map['fromUserName'] as String,
      toUserId: map['toUserId'] as String,
      toUserName: map['toUserName'] as String,
      message: map['message'] as String,
      emoji: map['emoji'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    )).toList();
  }

  // ==================== SYNC QUEUE ====================

  /// Add operation to sync queue
  Future<void> addToSyncQueue({
    required String operation,
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    final db = await _dbHelper.database;
    
    await db.insert('sync_queue', {
      'operation': operation,
      'collection': collection,
      'documentId': documentId,
      'data': jsonEncode(data),
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'retryCount': 0,
    });

    print('📤 Added to sync queue: $operation $collection/$documentId');
  }

  /// Get all pending sync operations
  Future<List<Map<String, dynamic>>> getSyncQueue() async {
    final db = await _dbHelper.database;
    
    return await db.query(
      'sync_queue',
      orderBy: 'createdAt ASC',
    );
  }

  /// Remove operation from sync queue
  Future<void> removeFromSyncQueue(int id) async {
    final db = await _dbHelper.database;
    
    await db.delete(
      'sync_queue',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Update sync queue retry count
  Future<void> updateSyncQueueRetry(int id, String error) async {
    final db = await _dbHelper.database;
    
    await db.rawUpdate(
      'UPDATE sync_queue SET retryCount = retryCount + 1, lastError = ? WHERE id = ?',
      [error, id],
    );
  }

  /// Clear sync queue
  Future<void> clearSyncQueue() async {
    final db = await _dbHelper.database;
    await db.delete('sync_queue');
    print('🗑️  Sync queue cleared');
  }
}
