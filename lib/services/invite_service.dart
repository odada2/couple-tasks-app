import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:couple_tasks/models/invite_model.dart';
import 'package:couple_tasks/models/user_model.dart';

/// Service for managing partner invitations
/// 
/// Handles:
/// - Generating unique invite codes
/// - Creating invite links
/// - Validating invites
/// - Accepting invites and creating couples
class InviteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Generate a unique 8-character invite code
  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Exclude confusing chars
    final random = Random.secure();
    return List.generate(8, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  /// Check if invite code already exists
  Future<bool> _inviteCodeExists(String code) async {
    final query = await _firestore
        .collection('invites')
        .where('inviteCode', isEqualTo: code)
        .limit(1)
        .get();
    
    return query.docs.isNotEmpty;
  }

  /// Generate unique invite code (ensures no duplicates)
  Future<String> _generateUniqueInviteCode() async {
    String code;
    int attempts = 0;
    const maxAttempts = 10;

    do {
      code = _generateInviteCode();
      attempts++;
      
      if (attempts >= maxAttempts) {
        throw Exception('Failed to generate unique invite code after $maxAttempts attempts');
      }
    } while (await _inviteCodeExists(code));

    return code;
  }

  /// Create a new partner invite
  /// 
  /// Returns the created PartnerInvite with invite code and link
  Future<PartnerInvite> createInvite({
    required String userId,
    required String userName,
    required String userEmail,
    int validityDays = 7, // Invite expires after 7 days
  }) async {
    try {
      // Generate unique invite code
      final inviteCode = await _generateUniqueInviteCode();
      
      // Create invite document
      final now = DateTime.now();
      final expiresAt = now.add(Duration(days: validityDays));
      
      final invite = PartnerInvite(
        id: '', // Will be set after Firestore creation
        inviteCode: inviteCode,
        createdBy: userId,
        createdByName: userName,
        createdByEmail: userEmail,
        createdAt: now,
        expiresAt: expiresAt,
        isUsed: false,
      );

      // Save to Firestore
      final docRef = await _firestore
          .collection('invites')
          .add(invite.toFirestore());

      print('✅ Invite created: $inviteCode (expires: ${expiresAt.toIso8601String()})');
      
      return invite.copyWith(id: docRef.id);
    } catch (e) {
      print('❌ Error creating invite: $e');
      rethrow;
    }
  }

  /// Get invite by code
  Future<PartnerInvite?> getInviteByCode(String inviteCode) async {
    try {
      final query = await _firestore
          .collection('invites')
          .where('inviteCode', isEqualTo: inviteCode.toUpperCase())
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        print('⚠️  Invite not found: $inviteCode');
        return null;
      }

      return PartnerInvite.fromFirestore(query.docs.first);
    } catch (e) {
      print('❌ Error getting invite: $e');
      return null;
    }
  }

  /// Validate invite code
  /// 
  /// Returns validation result with error message if invalid
  Future<InviteValidationResult> validateInvite(String inviteCode) async {
    try {
      final invite = await getInviteByCode(inviteCode);

      if (invite == null) {
        return InviteValidationResult(
          isValid: false,
          errorMessage: 'Invalid invite code. Please check and try again.',
        );
      }

      if (invite.isUsed) {
        return InviteValidationResult(
          isValid: false,
          errorMessage: 'This invite has already been used.',
        );
      }

      if (DateTime.now().isAfter(invite.expiresAt)) {
        return InviteValidationResult(
          isValid: false,
          errorMessage: 'This invite has expired. Please request a new one.',
        );
      }

      return InviteValidationResult(
        isValid: true,
        invite: invite,
      );
    } catch (e) {
      print('❌ Error validating invite: $e');
      return InviteValidationResult(
        isValid: false,
        errorMessage: 'Error validating invite. Please try again.',
      );
    }
  }

  /// Accept invite and create couple
  /// 
  /// Links the two users as a couple and marks invite as used
  Future<String> acceptInvite({
    required String inviteCode,
    required String acceptingUserId,
    required String acceptingUserName,
    required String acceptingUserEmail,
  }) async {
    try {
      // Validate invite
      final validation = await validateInvite(inviteCode);
      if (!validation.isValid) {
        throw Exception(validation.errorMessage);
      }

      final invite = validation.invite!;

      // Check if accepting user is not the same as inviter
      if (acceptingUserId == invite.createdBy) {
        throw Exception('You cannot accept your own invite!');
      }

      // Check if accepting user already has a couple
      final acceptingUserDoc = await _firestore
          .collection('users')
          .doc(acceptingUserId)
          .get();
      
      if (acceptingUserDoc.exists) {
        final userData = acceptingUserDoc.data() as Map<String, dynamic>;
        if (userData['coupleId'] != null) {
          throw Exception('You are already part of a couple.');
        }
      }

      // Check if inviter already has a couple (they might have accepted another invite)
      final inviterDoc = await _firestore
          .collection('users')
          .doc(invite.createdBy)
          .get();
      
      if (inviterDoc.exists) {
        final inviterData = inviterDoc.data() as Map<String, dynamic>;
        if (inviterData['coupleId'] != null) {
          throw Exception('This invite is no longer valid. The sender has already paired with someone else.');
        }
      }

      // Create couple
      final coupleRef = await _firestore.collection('couples').add({
        'user1Id': invite.createdBy,
        'user1Name': invite.createdByName,
        'user1Email': invite.createdByEmail,
        'user2Id': acceptingUserId,
        'user2Name': acceptingUserName,
        'user2Email': acceptingUserEmail,
        'createdAt': FieldValue.serverTimestamp(),
        'tasksCompleted': 0,
        'nudgesSent': 0,
      });

      final coupleId = coupleRef.id;

      // Update both users with couple ID
      await Future.wait([
        _firestore.collection('users').doc(invite.createdBy).update({
          'coupleId': coupleId,
          'partnerId': acceptingUserId,
          'partnerName': acceptingUserName,
          'partnerEmail': acceptingUserEmail,
          'updatedAt': FieldValue.serverTimestamp(),
        }),
        _firestore.collection('users').doc(acceptingUserId).update({
          'coupleId': coupleId,
          'partnerId': invite.createdBy,
          'partnerName': invite.createdByName,
          'partnerEmail': invite.createdByEmail,
          'updatedAt': FieldValue.serverTimestamp(),
        }),
      ]);

      // Mark invite as used
      await _firestore.collection('invites').doc(invite.id).update({
        'isUsed': true,
        'usedBy': acceptingUserId,
        'usedAt': FieldValue.serverTimestamp(),
        'coupleId': coupleId,
      });

      print('✅ Couple created: $coupleId');
      print('   User 1: ${invite.createdByName}');
      print('   User 2: $acceptingUserName');

      return coupleId;
    } catch (e) {
      print('❌ Error accepting invite: $e');
      rethrow;
    }
  }

  /// Get active invite for user
  /// 
  /// Returns the most recent valid invite created by the user
  Future<PartnerInvite?> getActiveInviteForUser(String userId) async {
    try {
      final query = await _firestore
          .collection('invites')
          .where('createdBy', isEqualTo: userId)
          .where('isUsed', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return null;
      }

      final invite = PartnerInvite.fromFirestore(query.docs.first);
      
      // Check if expired
      if (!invite.isValid) {
        return null;
      }

      return invite;
    } catch (e) {
      print('❌ Error getting active invite: $e');
      return null;
    }
  }

  /// Cancel/delete an invite
  Future<void> cancelInvite(String inviteId) async {
    try {
      await _firestore.collection('invites').doc(inviteId).delete();
      print('✅ Invite cancelled: $inviteId');
    } catch (e) {
      print('❌ Error cancelling invite: $e');
      rethrow;
    }
  }

  /// Check if user needs to invite partner (for gate logic)
  /// 
  /// Returns true if user has no couple and no active invite
  Future<bool> needsToInvitePartner(String userId) async {
    try {
      // Check if user has a couple
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        if (userData['coupleId'] != null) {
          return false; // Already has a couple
        }
      }

      // Check if user has an active invite
      final activeInvite = await getActiveInviteForUser(userId);
      
      // Needs to invite if no active invite exists
      return activeInvite == null;
    } catch (e) {
      print('❌ Error checking invite status: $e');
      return true; // Default to showing invite screen on error
    }
  }

  /// Get user's task count (for gate trigger logic)
  Future<int> getUserTaskCount(String userId) async {
    try {
      final tasksQuery = await _firestore
          .collection('tasks')
          .where('createdBy', isEqualTo: userId)
          .get();

      return tasksQuery.docs.length;
    } catch (e) {
      print('❌ Error getting task count: $e');
      return 0;
    }
  }

  /// Check if user should see mandatory partner gate
  /// 
  /// Returns true if user has created 2+ tasks but has no couple
  Future<bool> shouldShowPartnerGate(String userId) async {
    try {
      // Check if user has a couple
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        if (userData['coupleId'] != null) {
          return false; // Already has a couple
        }
      }

      // Check task count
      final taskCount = await getUserTaskCount(userId);
      
      // Show gate if user has 2 or more tasks
      return taskCount >= 2;
    } catch (e) {
      print('❌ Error checking gate status: $e');
      return false;
    }
  }
}

/// Result of invite validation
class InviteValidationResult {
  final bool isValid;
  final String? errorMessage;
  final PartnerInvite? invite;

  InviteValidationResult({
    required this.isValid,
    this.errorMessage,
    this.invite,
  });
}
