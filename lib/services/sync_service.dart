import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:couple_tasks/services/local_database_service.dart';
import 'package:couple_tasks/services/connectivity_service.dart';
import 'package:couple_tasks/models/task_model.dart';
import 'package:couple_tasks/models/user_model.dart';
import 'package:couple_tasks/models/couple_model.dart';

/// Sync service for Firestore-SQLite synchronization
/// 
/// Manages bidirectional sync between local SQLite and cloud Firestore
class SyncService {
  final LocalDatabaseService _localDb = LocalDatabaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ConnectivityService _connectivity = ConnectivityService.instance;

  StreamSubscription? _connectivitySubscription;
  bool _isSyncing = false;

  /// Initialize sync service
  void initialize() {
    print('🔄 Initializing sync service...');
    
    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.connectivityStream.listen((isOnline) {
      if (isOnline && !_isSyncing) {
        print('📡 Connection restored, starting sync...');
        syncAll();
      }
    });
  }

  /// Dispose sync service
  void dispose() {
    _connectivitySubscription?.cancel();
  }

  /// Sync all data (upload local changes, download remote changes)
  Future<void> syncAll() async {
    if (_isSyncing) {
      print('⏳ Sync already in progress, skipping...');
      return;
    }

    if (!_connectivity.isOnline) {
      print('📴 Offline, skipping sync');
      return;
    }

    _isSyncing = true;
    print('🔄 Starting full sync...');

    try {
      // 1. Upload local changes to Firestore
      await _uploadLocalChanges();

      // 2. Download remote changes from Firestore
      // (This would be done via real-time listeners in production)
      
      print('✅ Sync completed successfully');
    } catch (e) {
      print('❌ Sync error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Upload local changes to Firestore
  Future<void> _uploadLocalChanges() async {
    print('📤 Uploading local changes...');

    // Process sync queue
    final syncQueue = await _localDb.getSyncQueue();
    
    for (final item in syncQueue) {
      try {
        await _processSyncQueueItem(item);
        await _localDb.removeFromSyncQueue(item['id'] as int);
      } catch (e) {
        print('❌ Error processing sync item: $e');
        await _localDb.updateSyncQueueRetry(item['id'] as int, e.toString());
      }
    }

    // Upload unsynced tasks
    await _uploadUnsyncedTasks();
  }

  /// Process sync queue item
  Future<void> _processSyncQueueItem(Map<String, dynamic> item) async {
    final operation = item['operation'] as String;
    final collection = item['collection'] as String;
    final documentId = item['documentId'] as String;
    final data = jsonDecode(item['data'] as String) as Map<String, dynamic>;

    print('📤 Processing: $operation $collection/$documentId');

    switch (operation) {
      case 'create':
        await _firestore.collection(collection).doc(documentId).set(data);
        break;
      case 'update':
        await _firestore.collection(collection).doc(documentId).update(data);
        break;
      case 'delete':
        await _firestore.collection(collection).doc(documentId).delete();
        break;
    }
  }

  /// Upload unsynced tasks
  Future<void> _uploadUnsyncedTasks() async {
    final unsyncedTasks = await _localDb.getUnsyncedTasks();
    
    for (final task in unsyncedTasks) {
      try {
        await _firestore.collection('tasks').doc(task.id).set({
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
          'completedAt': task.completedAt,
          'completedBy': task.completedBy,
          'nudgeCount': task.nudgeCount,
          'lastNudgeAt': task.lastNudgeAt,
          'createdAt': task.createdAt,
          'updatedAt': task.updatedAt,
        });

        await _localDb.markTaskSynced(task.id);
        print('✅ Task synced: ${task.title}');
      } catch (e) {
        print('❌ Error syncing task: $e');
      }
    }
  }

  /// Download tasks from Firestore to local database
  Future<void> downloadTasks(String coupleId) async {
    if (!_connectivity.isOnline) {
      print('📴 Offline, skipping download');
      return;
    }

    try {
      print('📥 Downloading tasks from Firestore...');

      final snapshot = await _firestore
          .collection('tasks')
          .where('coupleId', isEqualTo: coupleId)
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final task = TaskModel(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'],
          dueDate: data['dueDate'] != null 
              ? (data['dueDate'] as Timestamp).toDate()
              : null,
          priority: data['priority'] ?? 'medium',
          assignedTo: data['assignedTo'],
          assignedToName: data['assignedToName'],
          createdBy: data['createdBy'] ?? '',
          createdByName: data['createdByName'] ?? '',
          coupleId: data['coupleId'] ?? '',
          isCompleted: data['isCompleted'] ?? false,
          completedAt: data['completedAt'] != null
              ? (data['completedAt'] as Timestamp).toDate()
              : null,
          completedBy: data['completedBy'],
          nudgeCount: data['nudgeCount'] ?? 0,
          lastNudgeAt: data['lastNudgeAt'] != null
              ? (data['lastNudgeAt'] as Timestamp).toDate()
              : null,
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          updatedAt: (data['updatedAt'] as Timestamp).toDate(),
        );

        await _localDb.createTaskLocal(task, syncStatus: 'synced');
      }

      print('✅ Tasks downloaded: ${snapshot.docs.length}');
    } catch (e) {
      print('❌ Error downloading tasks: $e');
    }
  }

  /// Download user data from Firestore
  Future<void> downloadUser(String userId) async {
    if (!_connectivity.isOnline) {
      print('📴 Offline, skipping download');
      return;
    }

    try {
      print('📥 Downloading user data...');

      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (!doc.exists) {
        print('⚠️  User not found in Firestore');
        return;
      }

      final data = doc.data()!;
      final user = UserModel(
        id: doc.id,
        email: data['email'] ?? '',
        displayName: data['displayName'],
        photoURL: data['photoURL'],
        coupleId: data['coupleId'],
        partnerId: data['partnerId'],
        partnerName: data['partnerName'],
        partnerEmail: data['partnerEmail'],
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      );

      await _localDb.saveUserLocal(user, syncStatus: 'synced');
      print('✅ User data downloaded');
    } catch (e) {
      print('❌ Error downloading user: $e');
    }
  }

  /// Download couple data from Firestore
  Future<void> downloadCouple(String coupleId) async {
    if (!_connectivity.isOnline) {
      print('📴 Offline, skipping download');
      return;
    }

    try {
      print('📥 Downloading couple data...');

      final doc = await _firestore.collection('couples').doc(coupleId).get();
      
      if (!doc.exists) {
        print('⚠️  Couple not found in Firestore');
        return;
      }

      final data = doc.data()!;
      final couple = CoupleModel(
        id: doc.id,
        user1Id: data['user1Id'] ?? '',
        user1Name: data['user1Name'] ?? '',
        user1Email: data['user1Email'] ?? '',
        user2Id: data['user2Id'] ?? '',
        user2Name: data['user2Name'] ?? '',
        user2Email: data['user2Email'] ?? '',
        tasksCompleted: data['tasksCompleted'] ?? 0,
        nudgesSent: data['nudgesSent'] ?? 0,
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      );

      await _localDb.saveCoupleLocal(couple, syncStatus: 'synced');
      print('✅ Couple data downloaded');
    } catch (e) {
      print('❌ Error downloading couple: $e');
    }
  }

  /// Setup real-time listeners for Firestore changes
  StreamSubscription? setupTasksListener(String coupleId) {
    if (!_connectivity.isOnline) {
      print('📴 Offline, cannot setup listener');
      return null;
    }

    print('👂 Setting up tasks listener for couple: $coupleId');

    return _firestore
        .collection('tasks')
        .where('coupleId', isEqualTo: coupleId)
        .snapshots()
        .listen((snapshot) async {
      for (final change in snapshot.docChanges) {
        final doc = change.doc;
        final data = doc.data();

        if (data == null) continue;

        final task = TaskModel(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'],
          dueDate: data['dueDate'] != null 
              ? (data['dueDate'] as Timestamp).toDate()
              : null,
          priority: data['priority'] ?? 'medium',
          assignedTo: data['assignedTo'],
          assignedToName: data['assignedToName'],
          createdBy: data['createdBy'] ?? '',
          createdByName: data['createdByName'] ?? '',
          coupleId: data['coupleId'] ?? '',
          isCompleted: data['isCompleted'] ?? false,
          completedAt: data['completedAt'] != null
              ? (data['completedAt'] as Timestamp).toDate()
              : null,
          completedBy: data['completedBy'],
          nudgeCount: data['nudgeCount'] ?? 0,
          lastNudgeAt: data['lastNudgeAt'] != null
              ? (data['lastNudgeAt'] as Timestamp).toDate()
              : null,
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          updatedAt: (data['updatedAt'] as Timestamp).toDate(),
        );

        switch (change.type) {
          case DocumentChangeType.added:
          case DocumentChangeType.modified:
            await _localDb.createTaskLocal(task, syncStatus: 'synced');
            print('✅ Task synced from Firestore: ${task.title}');
            break;
          case DocumentChangeType.removed:
            await _localDb.deleteTaskLocal(doc.id, syncStatus: 'synced');
            print('✅ Task deleted from local: ${doc.id}');
            break;
        }
      }
    }, onError: (error) {
      print('❌ Tasks listener error: $error');
    });
  }

  /// Get sync status
  Future<Map<String, dynamic>> getSyncStatus() async {
    final unsyncedCount = await _localDb.getUnsyncedCount();
    final syncQueue = await _localDb.getSyncQueue();
    
    return {
      'isOnline': _connectivity.isOnline,
      'isSyncing': _isSyncing,
      'unsyncedCount': unsyncedCount,
      'syncQueueCount': syncQueue.length,
    };
  }
}
