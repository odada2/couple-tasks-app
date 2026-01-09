import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Create or update user document
      if (userCredential.user != null) {
        await _createOrUpdateUserDocument(userCredential.user!);
      }

      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  // Create or update user document in Firestore
  Future<void> _createOrUpdateUserDocument(User user) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final userDoc = await userRef.get();

    if (!userDoc.exists) {
      // Create new user document
      final newUser = UserModel(
        id: user.uid,
        displayName: user.displayName ?? 'User',
        email: user.email ?? '',
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
        notifications: NotificationPreferences(),
      );
      await userRef.set(newUser.toFirestore());
    } else {
      // Update last active time
      await userRef.update({
        'lastActiveAt': Timestamp.now(),
      });
    }
  }

  // Get current user data
  Future<UserModel?> getCurrentUserData() async {
    if (currentUser == null) return null;

    final userDoc =
        await _firestore.collection('users').doc(currentUser!.uid).get();
    if (!userDoc.exists) return null;

    return UserModel.fromFirestore(userDoc);
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
