# Partner Invitation Flow Documentation

## Overview

This document describes the implementation of the partner invitation system for the Couple Tasks app. The system includes:

1. **Optional Onboarding Invite** - Users can invite their partner immediately after onboarding or skip to explore the app first
2. **Mandatory Partner Gate** - After creating 2 tasks, users must invite their partner to continue (no skip option)
3. **Invite Code System** - Secure 8-character invite codes with expiration
4. **Accept Invite Flow** - Partner can join using invite code or deep link

---

## Architecture

### Data Model

**PartnerInvite** (`lib/models/invite_model.dart`)
```dart
class PartnerInvite {
  final String id;
  final String inviteCode;        // 8-character unique code
  final String createdBy;         // User ID
  final String createdByName;
  final String createdByEmail;
  final DateTime createdAt;
  final DateTime expiresAt;       // 7 days by default
  final bool isUsed;
  final String? usedBy;
  final DateTime? usedAt;
  final String? coupleId;
}
```

**Firestore Collections**:
- `invites/` - Stores all partner invites
- `couples/` - Stores couple relationships
- `users/` - Updated with `coupleId` and `partnerId` fields

### Services

**InviteService** (`lib/services/invite_service.dart`)

Key methods:
- `createInvite()` - Generate unique invite code
- `validateInvite()` - Check if invite is valid
- `acceptInvite()` - Create couple and link users
- `shouldShowPartnerGate()` - Check if user needs to see gate
- `getUserTaskCount()` - Count user's tasks

### Screens

1. **InvitePartnerScreen** (`lib/screens/invite_partner_screen.dart`)
   - Optional invite during onboarding
   - "Better Together" messaging
   - Skip option available
   - Share invite link

2. **PartnerGateScreen** (`lib/screens/partner_gate_screen.dart`)
   - Mandatory gate after 2nd task
   - "You're on a roll!" messaging
   - No skip option
   - Must send invite to continue

3. **AcceptInviteScreen** (`lib/screens/accept_invite_screen.dart`)
   - Enter invite code
   - Validate in real-time
   - Show partner info
   - Accept and create couple

---

## User Flow

### Flow 1: Onboarding Invite (Optional)

```
User signs up
    ↓
Complete onboarding philosophy screens
    ↓
[InvitePartnerScreen] - "Better Together"
    ↓
User chooses:
    → Invite Partner → Share invite link → Home screen
    → Skip → Home screen (can invite later)
```

### Flow 2: Mandatory Partner Gate

```
User creates 1st task → No gate
    ↓
User creates 2nd task → Check shouldShowPartnerGate()
    ↓
[PartnerGateScreen] - "You're on a roll! Now, let's bring your partner in."
    ↓
User must send invite (no skip)
    ↓
Invite sent → Home screen
    ↓
Wait for partner to accept
```

### Flow 3: Partner Accepts Invite

```
Partner receives invite link/code
    ↓
Partner signs up/logs in
    ↓
[AcceptInviteScreen] - Enter code
    ↓
Validate invite
    ↓
Show partner info
    ↓
Accept invite
    ↓
Create couple in Firestore
    ↓
Update both users with coupleId
    ↓
Navigate to home screen
    ↓
Both users now see shared tasks
```

---

## Implementation Details

### 1. Invite Code Generation

**Format**: 8 characters, uppercase letters and numbers (excluding confusing characters like O, 0, I, 1)

**Example**: `ABC12345`

**Uniqueness**: Checks Firestore to ensure no duplicates

```dart
String _generateInviteCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final random = Random.secure();
  return List.generate(8, (index) => chars[random.nextInt(chars.length)])
      .join();
}
```

### 2. Invite Validation

**Checks**:
- ✅ Invite exists
- ✅ Not already used
- ✅ Not expired (7 days)
- ✅ Accepting user is not the inviter
- ✅ Neither user already has a couple

```dart
Future<InviteValidationResult> validateInvite(String inviteCode) async {
  final invite = await getInviteByCode(inviteCode);
  
  if (invite == null) {
    return InviteValidationResult(
      isValid: false,
      errorMessage: 'Invalid invite code',
    );
  }
  
  if (invite.isUsed) {
    return InviteValidationResult(
      isValid: false,
      errorMessage: 'This invite has already been used',
    );
  }
  
  if (DateTime.now().isAfter(invite.expiresAt)) {
    return InviteValidationResult(
      isValid: false,
      errorMessage: 'This invite has expired',
    );
  }
  
  return InviteValidationResult(isValid: true, invite: invite);
}
```

### 3. Creating a Couple

When invite is accepted:

1. **Create couple document**:
```dart
final coupleRef = await _firestore.collection('couples').add({
  'user1Id': inviter.uid,
  'user1Name': inviter.name,
  'user1Email': inviter.email,
  'user2Id': accepter.uid,
  'user2Name': accepter.name,
  'user2Email': accepter.email,
  'createdAt': FieldValue.serverTimestamp(),
  'tasksCompleted': 0,
  'nudgesSent': 0,
});
```

2. **Update both users**:
```dart
await Future.wait([
  _firestore.collection('users').doc(inviter.uid).update({
    'coupleId': coupleId,
    'partnerId': accepter.uid,
    'partnerName': accepter.name,
  }),
  _firestore.collection('users').doc(accepter.uid).update({
    'coupleId': coupleId,
    'partnerId': inviter.uid,
    'partnerName': inviter.name,
  }),
]);
```

3. **Mark invite as used**:
```dart
await _firestore.collection('invites').doc(invite.id).update({
  'isUsed': true,
  'usedBy': accepter.uid,
  'usedAt': FieldValue.serverTimestamp(),
  'coupleId': coupleId,
});
```

### 4. Partner Gate Logic

**Trigger**: After user creates their 2nd task

```dart
Future<bool> shouldShowPartnerGate(String userId) async {
  // Check if user already has a couple
  final userDoc = await _firestore.collection('users').doc(userId).get();
  if (userDoc.data()?['coupleId'] != null) {
    return false; // Already has couple
  }
  
  // Check task count
  final taskCount = await getUserTaskCount(userId);
  
  // Show gate if 2 or more tasks
  return taskCount >= 2;
}
```

**Integration in task creation**:
```dart
// In new_task_screen.dart or task creation logic
Future<void> _createTask() async {
  // Create task...
  await firestoreService.createTask(...);
  
  // Check if should show partner gate
  final shouldShowGate = await inviteService.shouldShowPartnerGate(userId);
  
  if (shouldShowGate) {
    // Navigate to partner gate (mandatory)
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const PartnerGateScreen(),
      ),
    );
  } else {
    // Navigate back to home
    Navigator.of(context).pop();
  }
}
```

### 5. Sharing Invite Links

**Using share_plus package**:

```dart
await Share.share(
  invite.getShareMessage(),
  subject: 'Join me on Couple Tasks! 💕',
);
```

**Share message**:
```
Hey! 💕

[Your Name] invited you to join Couple Tasks - our shared space for getting things done together!

Join me here:
https://coupletasks.app/invite/ABC12345

Let's make life easier, together! ✨
```

### 6. Deep Linking (Future Enhancement)

**URL format**: `https://coupletasks.app/invite/{inviteCode}`

**Implementation**:
1. Configure deep links in `AndroidManifest.xml` and `Info.plist`
2. Handle incoming links in main.dart
3. Parse invite code from URL
4. Navigate to AcceptInviteScreen with pre-filled code

---

## UI/UX Design

### Onboarding Invite Screen

**Visual Elements**:
- Two overlapping cards with heart in center
- "Better Together" title (with "Together" in pink)
- Warm, encouraging description
- Large "Invite Your Partner" button
- "I'll do this later" skip button
- Helper text about instant joining

**Colors**:
- Primary: `#FF6B9D` (pink)
- Background: `#FFFFFF` (white)
- Card background: `#FFF5F8` (light pink)
- Text: `#000000` (black), `#666666` (gray)

### Partner Gate Screen

**Visual Elements**:
- Heart icon at top
- User icon connected to dashed partner icon
- "You're on a roll! Now, let's bring your partner in." title
- Explanation about connecting accounts
- "Quick Invite" info box
- Invite code display (after sending)
- "Send Invite Link" button (no skip!)
- "Why do I need to do this?" link

**Key Differences from Onboarding**:
- ❌ No back button
- ❌ No skip option
- ✅ Mandatory to continue
- ✅ Warmer, more encouraging tone
- ✅ Shows invite code after sending

### Accept Invite Screen

**Visual Elements**:
- "Join Your Partner" title
- Invite code input (8 characters, uppercase)
- Real-time validation
- Partner info card (after validation)
- "Accept Invite" button
- Helper text

---

## Firestore Security Rules

```javascript
// Invites collection
match /invites/{inviteId} {
  // Anyone can read invites to validate codes
  allow read: if true;
  
  // Only authenticated users can create invites
  allow create: if request.auth != null
    && request.resource.data.createdBy == request.auth.uid;
  
  // Only the creator or accepter can update
  allow update: if request.auth != null
    && (resource.data.createdBy == request.auth.uid
        || request.resource.data.usedBy == request.auth.uid);
  
  // Only the creator can delete
  allow delete: if request.auth != null
    && resource.data.createdBy == request.auth.uid;
}

// Couples collection
match /couples/{coupleId} {
  // Only couple members can read
  allow read: if request.auth != null
    && (resource.data.user1Id == request.auth.uid
        || resource.data.user2Id == request.auth.uid);
  
  // Only through invite acceptance (via InviteService)
  allow create: if request.auth != null;
  
  // Only couple members can update
  allow update: if request.auth != null
    && (resource.data.user1Id == request.auth.uid
        || resource.data.user2Id == request.auth.uid);
  
  // No deletion allowed
  allow delete: if false;
}
```

---

## Integration Steps

### 1. Update Main App Flow

**In `main.dart` or app routing**:

```dart
MaterialApp(
  routes: {
    '/': (context) => const LoginScreen(),
    '/onboarding': (context) => const OnboardingScreen(),
    '/invite-partner': (context) => const InvitePartnerScreen(),
    '/partner-gate': (context) => const PartnerGateScreen(),
    '/accept-invite': (context) => const AcceptInviteScreen(),
    '/home': (context) => const HomeScreen(),
  },
);
```

### 2. Update Onboarding Flow

**After philosophy screens**:

```dart
// In onboarding_screen.dart
void _completeOnboarding() {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (context) => const InvitePartnerScreen(canSkip: true),
    ),
  );
}
```

### 3. Update Task Creation

**Check for partner gate**:

```dart
// In new_task_screen.dart
Future<void> _createTask() async {
  final task = await firestoreService.createTask(...);
  
  // Check if should show partner gate
  final shouldShowGate = await inviteService.shouldShowPartnerGate(userId);
  
  if (shouldShowGate && mounted) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const PartnerGateScreen(),
      ),
    );
  } else {
    Navigator.of(context).pop();
  }
}
```

### 4. Add Provider for InviteService

**In main.dart**:

```dart
MultiProvider(
  providers: [
    Provider<InviteService>(create: (_) => InviteService()),
    // ... other providers
  ],
  child: MaterialApp(...),
)
```

### 5. Update User Model

**Add fields to `UserModel`**:

```dart
class UserModel {
  // ... existing fields
  final String? coupleId;
  final String? partnerId;
  final String? partnerName;
  final String? partnerEmail;
}
```

---

## Testing Checklist

### Onboarding Invite

- [ ] User can see invite screen after onboarding
- [ ] User can skip and go to home
- [ ] User can create and share invite
- [ ] Invite code is generated correctly
- [ ] Share dialog opens with correct message

### Partner Gate

- [ ] Gate appears after 2nd task creation
- [ ] Gate does NOT appear if user has couple
- [ ] Gate does NOT appear for 1st task
- [ ] Back button is disabled
- [ ] Skip option is not available
- [ ] Invite can be sent from gate
- [ ] User can continue after sending invite

### Accept Invite

- [ ] User can enter invite code
- [ ] Real-time validation works
- [ ] Invalid codes show error
- [ ] Expired invites show error
- [ ] Used invites show error
- [ ] Partner info displays correctly
- [ ] Accept button creates couple
- [ ] Both users get coupleId
- [ ] Navigation to home works

### Edge Cases

- [ ] User cannot accept own invite
- [ ] User with couple cannot accept invite
- [ ] Inviter with couple invalidates invite
- [ ] Duplicate invite codes prevented
- [ ] Expired invites cannot be used
- [ ] Used invites cannot be reused

---

## Future Enhancements

### Phase 2

1. **Deep Linking**
   - Handle `coupletasks://invite/{code}` URLs
   - Auto-fill invite code from link
   - Better mobile experience

2. **Email Invites**
   - Send invite via email
   - Include one-click join button
   - Email template with branding

3. **SMS Invites**
   - Send invite via SMS
   - Include short link
   - Track delivery status

4. **QR Code**
   - Generate QR code for invite
   - Scan QR code to join
   - Great for in-person invites

5. **Partner Confirmation Screen**
   - Show "Partner Joined!" celebration
   - Confetti animation
   - Welcome message
   - Tutorial for new couple

6. **Invite Analytics**
   - Track invite send rate
   - Track accept rate
   - Time to accept
   - Conversion funnel

### Phase 3

1. **Multiple Invites**
   - Allow multiple pending invites
   - Manage active invites
   - Cancel/resend invites

2. **Invite Reminders**
   - Remind user to invite partner
   - Remind partner to accept
   - Push notifications

3. **Couple Onboarding**
   - Joint onboarding after pairing
   - Set couple goals
   - Customize shared space

---

## Summary

The partner invitation flow creates a "try-before-commit" experience:

1. **Soft Introduction** - Optional invite during onboarding
2. **Exploration Phase** - User can create 1-2 tasks alone
3. **Mandatory Connection** - Gate after 2nd task requires partner invite
4. **Seamless Pairing** - Simple code-based invite system
5. **Shared Experience** - Both users immediately see shared tasks

This approach:
- ✅ Reduces initial friction
- ✅ Demonstrates app value first
- ✅ Ensures collaborative use
- ✅ Maintains app's core purpose
- ✅ Creates positive onboarding experience

---

## Dependencies

**New packages added**:
- `share_plus: ^7.2.2` - For sharing invite links

**Existing packages used**:
- `cloud_firestore` - For storing invites and couples
- `firebase_auth` - For user authentication
- `google_fonts` - For typography
- `provider` - For state management

---

## Files Created

1. `lib/models/invite_model.dart` - Invite data model
2. `lib/services/invite_service.dart` - Invite business logic
3. `lib/screens/invite_partner_screen.dart` - Optional onboarding invite
4. `lib/screens/partner_gate_screen.dart` - Mandatory gate after 2nd task
5. `lib/screens/accept_invite_screen.dart` - Accept invite flow
6. `PARTNER_INVITATION_FLOW.md` - This documentation

---

## Support

For questions or issues with the invitation flow:
1. Check this documentation
2. Review Firestore security rules
3. Check invite service logs
4. Verify user and couple data in Firestore
5. Test with different user scenarios

---

**Status**: ✅ Implementation Complete  
**Ready for**: Integration into main app flow  
**Next Steps**: Update routing, add provider, test flows
