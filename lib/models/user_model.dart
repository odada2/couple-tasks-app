import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String displayName;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final String? coupleId;
  final NotificationPreferences notifications;
  final List<String> deviceTokens;

  UserModel({
    required this.id,
    required this.displayName,
    required this.email,
    this.photoUrl,
    required this.createdAt,
    required this.lastActiveAt,
    this.coupleId,
    required this.notifications,
    this.deviceTokens = const [],
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastActiveAt: (data['lastActiveAt'] as Timestamp).toDate(),
      coupleId: data['coupleId'],
      notifications: NotificationPreferences.fromMap(
          data['notifications'] ?? {}),
      deviceTokens: List<String>.from(data['deviceTokens'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActiveAt': Timestamp.fromDate(lastActiveAt),
      'coupleId': coupleId,
      'notifications': notifications.toMap(),
      'deviceTokens': deviceTokens,
    };
  }
}

class NotificationPreferences {
  final bool nudgesEnabled;
  final bool remindersEnabled;
  final QuietHours? quietHours;

  NotificationPreferences({
    this.nudgesEnabled = true,
    this.remindersEnabled = true,
    this.quietHours,
  });

  factory NotificationPreferences.fromMap(Map<String, dynamic> map) {
    return NotificationPreferences(
      nudgesEnabled: map['nudgesEnabled'] ?? true,
      remindersEnabled: map['remindersEnabled'] ?? true,
      quietHours: map['quietHours'] != null
          ? QuietHours.fromMap(map['quietHours'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nudgesEnabled': nudgesEnabled,
      'remindersEnabled': remindersEnabled,
      'quietHours': quietHours?.toMap(),
    };
  }
}

class QuietHours {
  final String start;
  final String end;

  QuietHours({required this.start, required this.end});

  factory QuietHours.fromMap(Map<String, dynamic> map) {
    return QuietHours(
      start: map['start'] ?? '22:00',
      end: map['end'] ?? '07:00',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'start': start,
      'end': end,
    };
  }
}
