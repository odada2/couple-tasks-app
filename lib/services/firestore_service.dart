import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/couple_model.dart';
import '../models/task_model.dart';
import '../models/nudge_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Couple operations
  Future<CoupleModel?> getCouple(String coupleId) async {
    final doc = await _firestore.collection('couples').doc(coupleId).get();
    if (!doc.exists) return null;
    return CoupleModel.fromFirestore(doc);
  }

  Future<String> createCouple(String userId1, String userId2,
      {String? coupleName}) async {
    final coupleRef = _firestore.collection('couples').doc();
    final couple = CoupleModel(
      id: coupleRef.id,
      partnerIds: [userId1, userId2],
      createdAt: DateTime.now(),
      name: coupleName,
    );

    await coupleRef.set(couple.toFirestore());

    // Update both users with coupleId
    await _firestore.collection('users').doc(userId1).update({
      'coupleId': coupleRef.id,
    });
    await _firestore.collection('users').doc(userId2).update({
      'coupleId': coupleRef.id,
    });

    return coupleRef.id;
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) return null;
    return UserModel.fromFirestore(querySnapshot.docs.first);
  }

  // Task operations
  Stream<List<TaskModel>> getTasks(String coupleId) {
    return _firestore
        .collection('tasks')
        .where('coupleId', isEqualTo: coupleId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList());
  }

  Future<String> createTask({
    required String coupleId,
    required String title,
    String? description,
    required String createdByUserId,
    String? assignedToUserId,
    DateTime? dueDate,
  }) async {
    final taskRef = _firestore.collection('tasks').doc();
    final now = DateTime.now();

    final task = TaskModel(
      id: taskRef.id,
      coupleId: coupleId,
      title: title,
      description: description,
      createdByUserId: createdByUserId,
      assignedToUserId: assignedToUserId,
      dueDate: dueDate,
      createdAt: now,
      updatedAt: now,
    );

    await taskRef.set(task.toFirestore());
    return taskRef.id;
  }

  Future<void> updateTask(String taskId, Map<String, dynamic> updates) async {
    updates['updatedAt'] = Timestamp.now();
    await _firestore.collection('tasks').doc(taskId).update(updates);
  }

  Future<void> completeTask(String taskId) async {
    await updateTask(taskId, {
      'status': 'done',
      'completedAt': Timestamp.now(),
    });
  }

  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }

  // Nudge operations
  Future<void> sendNudge({
    required String taskId,
    required String coupleId,
    required String fromUserId,
    required String toUserId,
    required String emoji,
    String? customMessage,
  }) async {
    final nudgeRef = _firestore.collection('nudges').doc();
    final nudge = NudgeModel(
      id: nudgeRef.id,
      taskId: taskId,
      coupleId: coupleId,
      fromUserId: fromUserId,
      toUserId: toUserId,
      emoji: emoji,
      customMessage: customMessage,
      createdAt: DateTime.now(),
    );

    await nudgeRef.set(nudge.toFirestore());

    // Increment nudge count on task
    await _firestore.collection('tasks').doc(taskId).update({
      'nudgesCount': FieldValue.increment(1),
    });
  }

  Stream<List<NudgeModel>> getNudgesForTask(String taskId) {
    return _firestore
        .collection('nudges')
        .where('taskId', isEqualTo: taskId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => NudgeModel.fromFirestore(doc)).toList());
  }

  // Get partner user
  Future<UserModel?> getPartner(String coupleId, String currentUserId) async {
    final couple = await getCouple(coupleId);
    if (couple == null) return null;

    final partnerId =
        couple.partnerIds.firstWhere((id) => id != currentUserId);
    final partnerDoc =
        await _firestore.collection('users').doc(partnerId).get();

    if (!partnerDoc.exists) return null;
    return UserModel.fromFirestore(partnerDoc);
  }
}
