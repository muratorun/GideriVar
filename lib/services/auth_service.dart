import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Simüle edilmiş auth durumu - Firebase entegrasyonunda değiştirilecek
  bool _isAuthenticated = false;
  String? _currentUserId;

  bool get isAuthenticated => _isAuthenticated;
  String? get currentUserId => _currentUserId;

  // Email/Password ile kayıt
  Future<bool> signUpWithEmailPassword(String email, String password) async {
    try {
      // Firebase Auth entegrasyonu eklenecek
      await Future.delayed(const Duration(seconds: 2)); // Simülasyon
      _isAuthenticated = true;
      _currentUserId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      return true;
    } catch (e) {
      debugPrint('Sign up error: $e');
      return false;
    }
  }

  // Email/Password ile giriş
  Future<bool> signInWithEmailPassword(String email, String password) async {
    try {
      // Firebase Auth entegrasyonu eklenecek
      await Future.delayed(const Duration(seconds: 2)); // Simülasyon
      _isAuthenticated = true;
      _currentUserId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      return true;
    } catch (e) {
      debugPrint('Sign in error: $e');
      return false;
    }
  }

  // Google ile giriş
  Future<bool> signInWithGoogle() async {
    try {
      // Google Sign In entegrasyonu eklenecek
      await Future.delayed(const Duration(seconds: 2)); // Simülasyon
      _isAuthenticated = true;
      _currentUserId = 'google_user_${DateTime.now().millisecondsSinceEpoch}';
      return true;
    } catch (e) {
      debugPrint('Google sign in error: $e');
      return false;
    }
  }

  // Çıkış
  Future<void> signOut() async {
    try {
      // Firebase Auth sign out eklenecek
      _isAuthenticated = false;
      _currentUserId = null;
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  // Şifre sıfırlama
  Future<bool> resetPassword(String email) async {
    try {
      // Firebase Auth password reset eklenecek
      await Future.delayed(const Duration(seconds: 1)); // Simülasyon
      return true;
    } catch (e) {
      debugPrint('Password reset error: $e');
      return false;
    }
  }

  // Mevcut kullanıcıyı getir
  Future<UserModel?> getCurrentUser() async {
    if (!_isAuthenticated || _currentUserId == null) {
      return null;
    }

    // Simüle edilmiş kullanıcı verisi - Firebase'den gelecek
    return UserModel(
      id: _currentUserId!,
      email: 'user@example.com',
      displayName: 'Test User',
      createdAt: DateTime.now(),
      purchaseLimit: AppConstants.defaultPurchaseLimit,
      currentPurchases: 0,
      region: 'İstanbul',
    );
  }
}
