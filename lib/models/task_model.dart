import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String coupleId;
  final String title;
  final String? description;
  final String createdByUserId;
  final String? assignedToUserId;
  final String status;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final DateTime? lastReminderAt;
  final int reminderCount;
  final int nudgesCount;

  TaskModel({
    required this.id,
    required this.coupleId,
    required this.title,
    this.description,
    required this.createdByUserId,
    this.assignedToUserId,
    this.status = 'pending',
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.lastReminderAt,
    this.reminderCount = 0,
    this.nudgesCount = 0,
  });

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      coupleId: data['coupleId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'],
      createdByUserId: data['createdByUserId'] ?? '',
      assignedToUserId: data['assignedToUserId'],
      status: data['status'] ?? 'pending',
      dueDate: data['dueDate'] != null
          ? (data['dueDate'] as Timestamp).toDate()
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      lastReminderAt: data['lastReminderAt'] != null
          ? (data['lastReminderAt'] as Timestamp).toDate()
          : null,
      reminderCount: data['reminderCount'] ?? 0,
      nudgesCount: data['nudgesCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'coupleId': coupleId,
      'title': title,
      'description': description,
      'createdByUserId': createdByUserId,
      'assignedToUserId': assignedToUserId,
      'status': status,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'lastReminderAt':
          lastReminderAt != null ? Timestamp.fromDate(lastReminderAt!) : null,
      'reminderCount': reminderCount,
      'nudgesCount': nudgesCount,
    };
  }

  TaskModel copyWith({
    String? id,
    String? coupleId,
    String? title,
    String? description,
    String? createdByUserId,
    String? assignedToUserId,
    String? status,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    DateTime? lastReminderAt,
    int? reminderCount,
    int? nudgesCount,
  }) {
    return TaskModel(
      id: id ?? this.id,
      coupleId: coupleId ?? this.coupleId,
      title: title ?? this.title,
      description: description ?? this.description,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      assignedToUserId: assignedToUserId ?? this.assignedToUserId,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      lastReminderAt: lastReminderAt ?? this.lastReminderAt,
      reminderCount: reminderCount ?? this.reminderCount,
      nudgesCount: nudgesCount ?? this.nudgesCount,
    );
  }
}
