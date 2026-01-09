import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for partner invitation links
/// 
/// Stores invitation codes that allow partners to join a couple
class PartnerInvite {
  final String id;
  final String inviteCode; // Unique 8-character code
  final String createdBy; // User ID who created the invite
  final String createdByName; // Name of inviter
  final String createdByEmail; // Email of inviter
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isUsed;
  final String? usedBy; // User ID who used the invite
  final DateTime? usedAt;
  final String? coupleId; // Couple ID created after invite is used

  PartnerInvite({
    required this.id,
    required this.inviteCode,
    required this.createdBy,
    required this.createdByName,
    required this.createdByEmail,
    required this.createdAt,
    required this.expiresAt,
    this.isUsed = false,
    this.usedBy,
    this.usedAt,
    this.coupleId,
  });

  /// Create from Firestore document
  factory PartnerInvite.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PartnerInvite(
      id: doc.id,
      inviteCode: data['inviteCode'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdByName: data['createdByName'] ?? '',
      createdByEmail: data['createdByEmail'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
      isUsed: data['isUsed'] ?? false,
      usedBy: data['usedBy'],
      usedAt: data['usedAt'] != null 
          ? (data['usedAt'] as Timestamp).toDate() 
          : null,
      coupleId: data['coupleId'],
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'inviteCode': inviteCode,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdByEmail': createdByEmail,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'isUsed': isUsed,
      'usedBy': usedBy,
      'usedAt': usedAt != null ? Timestamp.fromDate(usedAt!) : null,
      'coupleId': coupleId,
    };
  }

  /// Check if invite is valid (not used and not expired)
  bool get isValid {
    return !isUsed && DateTime.now().isBefore(expiresAt);
  }

  /// Get invite link
  String getInviteLink() {
    // TODO: Replace with your actual app deep link domain
    return 'https://coupletasks.app/invite/$inviteCode';
  }

  /// Get shareable message
  String getShareMessage() {
    return '''
Hey! 💕

$createdByName invited you to join Couple Tasks - our shared space for getting things done together!

Join me here:
${getInviteLink()}

Let's make life easier, together! ✨
''';
  }

  /// Copy with method for updates
  PartnerInvite copyWith({
    String? id,
    String? inviteCode,
    String? createdBy,
    String? createdByName,
    String? createdByEmail,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isUsed,
    String? usedBy,
    DateTime? usedAt,
    String? coupleId,
  }) {
    return PartnerInvite(
      id: id ?? this.id,
      inviteCode: inviteCode ?? this.inviteCode,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      createdByEmail: createdByEmail ?? this.createdByEmail,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isUsed: isUsed ?? this.isUsed,
      usedBy: usedBy ?? this.usedBy,
      usedAt: usedAt ?? this.usedAt,
      coupleId: coupleId ?? this.coupleId,
    );
  }
}
