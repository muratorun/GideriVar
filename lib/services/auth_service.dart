import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Android ve iOS için güncel versiyon
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Auth durumu
  bool get isAuthenticated => _auth.currentUser != null;
  String? get currentUserId => _auth.currentUser?.uid;

  // Email/Password ile kayıt
  Future<bool> signUpWithEmailPassword(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user != null;
    } catch (e) {
      debugPrint('Sign up error: $e');
      return false;
    }
  }

  // Email/Password ile giriş
  Future<bool> signInWithEmailPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user != null;
    } catch (e) {
      debugPrint('Sign in error: $e');
      return false;
    }
  }

    // Google ile giriş (Google Sign-In 7.x API - Android ve iOS uyumlu)
  Future<bool> signInWithGoogle() async {
    try {
      debugPrint('Google Sign-In process started');
      
      // Google Sign-In 7.x API - authenticate() kullan
      final GoogleSignInAccount? googleAccount = await GoogleSignIn.instance.authenticate();
      
      if (googleAccount == null) {
        debugPrint('Google Sign-In cancelled by user');
        return false;
      }

      // Authorization için access token al
      final scopes = <String>['email', 'profile'];
      final authClient = googleAccount.authorizationClient;
      final authorization = await authClient.authorizeScopes(scopes);
      
      // Authentication data al
      final GoogleSignInAuthentication googleAuth = googleAccount.authentication;

      // Firebase credential oluştur
      final credential = GoogleAuthProvider.credential(
        accessToken: authorization.accessToken, // Authorization client'dan access token
        idToken: googleAuth.idToken,
      );

      // Firebase'e Google credential ile giriş yap
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        debugPrint('Google Sign-In successful: ${userCredential.user!.email}');
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
      email: user.email ?? 'user@example.com',
      displayName: user.displayName ?? 'User',
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      purchaseLimit: AppConstants.defaultPurchaseLimit,
      currentPurchases: 0,
      region: 'İstanbul',
    );
  }
}
