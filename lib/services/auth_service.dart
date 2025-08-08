import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Android ve iOS için güncel versiyon
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'auth_persistence_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Auth durumu
  bool get isAuthenticated => _auth.currentUser != null || AuthPersistenceService.isUserLoggedIn();
  String? get currentUserId => _auth.currentUser?.uid ?? AuthPersistenceService.getSavedUserId();

  // Email/Password ile kayıt
  Future<bool> signUpWithEmailPassword(String email, String password) async {
    try {
      // Email formatını kontrol et
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        debugPrint('Sign up error: Invalid email format');
        return false;
      }

      // Şifre uzunluğunu kontrol et
      if (password.length < 6) {
        debugPrint('Sign up error: Password too short');
        return false;
      }

      debugPrint('Attempting to create user with email: $email');
      
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        debugPrint('User created successfully: ${credential.user!.uid}');
        
        // Hive'a kaydet
        await AuthPersistenceService.saveUserSession(
          userId: credential.user!.uid,
          email: credential.user!.email ?? email,
          displayName: credential.user!.displayName,
        );
        
        return true;
      } else {
        debugPrint('Sign up error: No user returned from createUserWithEmailAndPassword');
        return false;
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Sign up FirebaseAuthException: ${e.code} - ${e.message}');
      
      // Production hata detayları
      switch (e.code) {
        case 'weak-password':
          debugPrint('Production Error: Password is too weak');
          break;
        case 'email-already-in-use':
          debugPrint('Production Error: Email already registered');
          break;
        case 'internal-error':
          debugPrint('Production Error: Firebase project configuration issue - check OAuth clients');
          break;
        default:
          debugPrint('Production Error: ${e.code}');
      }
      return false;
    } catch (e) {
      debugPrint('Sign up error: $e');
      return false;
    }
  }

  // Email/Password ile giriş
  Future<bool> signInWithEmailPassword(String email, String password) async {
    try {
      // Email formatını kontrol et
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        debugPrint('Sign in error: Invalid email format');
        return false;
      }

      debugPrint('Attempting to sign in with email: $email');
      
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        debugPrint('User signed in successfully: ${credential.user!.uid}');
        
        // Hive'a kaydet
        await AuthPersistenceService.saveUserSession(
          userId: credential.user!.uid,
          email: credential.user!.email ?? email,
          displayName: credential.user!.displayName,
        );
        
        return true;
      } else {
        debugPrint('Sign in error: No user returned from signInWithEmailAndPassword');
        return false;
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Sign in FirebaseAuthException: ${e.code} - ${e.message}');
      
      // Production hata detayları
      switch (e.code) {
        case 'user-not-found':
          debugPrint('Production Error: No user found with this email');
          break;
        case 'wrong-password':
          debugPrint('Production Error: Incorrect password');
          break;
        case 'internal-error':
          debugPrint('Production Error: Firebase project configuration issue - check OAuth clients');
          break;
        default:
          debugPrint('Production Error: ${e.code}');
      }
      return false;
    } catch (e) {
      debugPrint('Sign in error: $e');
      return false;
    }
  }

  // Google ile giriş (Google Sign-In 7.x official API)
  Future<bool> signInWithGoogle() async {
    try {
      debugPrint('Google Sign-In process started');
      
      // Google Sign-In 7.x correct usage
      final GoogleSignInAccount? account = await GoogleSignIn.instance.authenticate();
      
      if (account == null) {
        debugPrint('Google Sign-In cancelled by user');
        return false;
      }

      // Authentication token'ları al - 7.x'de sadece idToken var
      final GoogleSignInAuthentication auth = await account.authentication;

      // Firebase credential oluştur - 7.x'de sadece idToken kullan
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: auth.idToken,
      );

      // Firebase'e Google credential ile giriş yap
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        debugPrint('Google Sign-In successful: ${userCredential.user!.email}');
        
        // Hive'a kaydet
        await AuthPersistenceService.saveUserSession(
          userId: userCredential.user!.uid,
          email: userCredential.user!.email ?? 'google@giderivar.com',
          displayName: userCredential.user!.displayName,
        );
        
        return true;
      } else {
        debugPrint('Google Sign-In failed: No user returned');
        return false;
      }
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      return false;
    }
  }

  // Çıkış
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await AuthPersistenceService.clearUserSession();
      debugPrint('User signed out successfully');
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  // Şifre sıfırlama
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      debugPrint('Password reset error: $e');
      return false;
    }
  }

  // Mevcut kullanıcıyı getir
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }

    // Firebase kullanıcı verisi
    return UserModel(
      id: user.uid,
      email: user.email ?? 'kullanici@giderivar.com',
      displayName: user.displayName ?? 'GideriVar Kullanıcısı',
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      purchaseLimit: AppConstants.defaultPurchaseLimit,
      currentPurchases: 0,
      region: 'İstanbul',
    );
  }
}
