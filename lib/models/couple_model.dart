import 'package:cloud_firestore/cloud_firestore.dart';

class CoupleModel {
  final String id;
  final List<String> partnerIds;
  final DateTime createdAt;
  final String status;
  final String? name;
  final String tone;
  final int reminderWindowHours;

  CoupleModel({
    required this.id,
    required this.partnerIds,
    required this.createdAt,
    this.status = 'active',
    this.name,
    this.tone = 'playful',
    this.reminderWindowHours = 24,
  });

  factory CoupleModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CoupleModel(
      id: doc.id,
      partnerIds: List<String>.from(data['partnerIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'active',
      name: data['name'],
      tone: data['tone'] ?? 'playful',
      reminderWindowHours: data['reminderWindowHours'] ?? 24,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'partnerIds': partnerIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
      'name': name,
      'tone': tone,
      'reminderWindowHours': reminderWindowHours,
    };
  }
}
