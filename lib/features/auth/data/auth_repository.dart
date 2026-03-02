
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import '../domain/user_model.dart';
import '../../../core/enums/user_role.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
    kIsWeb ? null : GoogleSignIn(),
  );
});

final authStateChangesProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn? _googleSignIn;

  AuthRepository(this._auth, this._firestore, this._googleSignIn);

  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      final user = await _getUserData(firebaseUser.uid);
      if (user == null) {
        // User exists in Auth but not in Firestore -> Force Logout
        await _auth.signOut(); 
        return null;
      }
      return user;
    });
  }

  Future<AppUser?> _getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return AppUser.fromMap(doc.data()!, uid);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      return null;
    }
  }

  Future<AppUser?> signInWithGoogle() async {
    try {
      UserCredential? userCredential;

      if (kIsWeb) {
        GoogleAuthProvider authProvider = GoogleAuthProvider();
        userCredential = await _auth.signInWithPopup(authProvider);
      } else {
        if (_googleSignIn == null) {
           throw Exception('Google Sign In is not available on this platform configuration.');
        }
        final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
        if (googleUser == null) return null; // Cancelled

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await _auth.signInWithCredential(credential);
      }

      if (userCredential.user != null) {
        final user = userCredential.user!;
        
        // 1. Try fetching by UID first
        var doc = await _firestore.collection('users').doc(user.uid).get();
        
        if (!doc.exists) {
          // 2. Try fetching by Email (pre-registered users)
          final emailQuery = await _firestore
              .collection('users')
              .where('email', isEqualTo: user.email)
              .limit(1)
              .get();
          
          if (emailQuery.docs.isNotEmpty) {
            final oldDoc = emailQuery.docs.first;
            final userData = oldDoc.data();
            
            // Migrate document to real UID
            await _firestore.collection('users').doc(user.uid).set({
              ...userData,
              'displayName': userData['displayName'] ?? user.displayName,
            });
            
            // Delete old placeholder document if UID was different
            if (oldDoc.id != user.uid) {
              await _firestore.collection('users').doc(oldDoc.id).delete();
            }
            
            doc = await _firestore.collection('users').doc(user.uid).get();
          }
        }

        if (!doc.exists) {
           await signOut(); // Force signout immediately
           throw Exception('Akses Ditolak: Akun ${user.email} tidak terdaftar di sistem.');
        } else {
           return AppUser.fromMap(doc.data()!, user.uid);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Sign in failed: $e');
      rethrow;
    }
  }

  Future<AppUser?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await _getUserData(user.uid);
  }

  Future<void> signOut() async {
    await _googleSignIn?.signOut();
    await _auth.signOut();
  }
}
