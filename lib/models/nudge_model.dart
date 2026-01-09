import 'package:cloud_firestore/cloud_firestore.dart';

class NudgeModel {
  final String id;
  final String taskId;
  final String coupleId;
  final String fromUserId;
  final String toUserId;
  final String emoji;
  final String? messageTemplateId;
  final String? customMessage;
  final DateTime createdAt;

  NudgeModel({
    required this.id,
    required this.taskId,
    required this.coupleId,
    required this.fromUserId,
    required this.toUserId,
    required this.emoji,
    this.messageTemplateId,
    this.customMessage,
    required this.createdAt,
  });

  factory NudgeModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return NudgeModel(
      id: doc.id,
      taskId: data['taskId'] ?? '',
      coupleId: data['coupleId'] ?? '',
      fromUserId: data['fromUserId'] ?? '',
      toUserId: data['toUserId'] ?? '',
      emoji: data['emoji'] ?? '💛',
      messageTemplateId: data['messageTemplateId'],
      customMessage: data['customMessage'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'taskId': taskId,
      'coupleId': coupleId,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'emoji': emoji,
      'messageTemplateId': messageTemplateId,
      'customMessage': customMessage,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
