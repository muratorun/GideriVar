import 'package:hive_flutter/hive_flutter.dart';

class AuthPersistenceService {
  static const String _boxName = 'authBox';
  static const String _userIdKey = 'userId';
  static const String _userEmailKey = 'userEmail';
  static const String _userNameKey = 'userName';
  static const String _isLoggedInKey = 'isLoggedIn';
  
  static late Box _authBox;
  
  // Initialize Hive box
  static Future<void> initialize() async {
    _authBox = await Hive.openBox(_boxName);
  }
  
  // Save user session
  static Future<void> saveUserSession({
    required String userId,
    required String email,
    String? displayName,
  }) async {
    await _authBox.put(_userIdKey, userId);
    await _authBox.put(_userEmailKey, email);
    await _authBox.put(_userNameKey, displayName ?? 'Kullanıcı');
    await _authBox.put(_isLoggedInKey, true);
  }
  
  // Check if user is logged in
  static bool isUserLoggedIn() {
    return _authBox.get(_isLoggedInKey, defaultValue: false);
  }
  
  // Get saved user ID
  static String? getSavedUserId() {
    return _authBox.get(_userIdKey);
  }
  
  // Get saved user email
  static String? getSavedUserEmail() {
    return _authBox.get(_userEmailKey);
  }
  
  // Get saved user name
  static String? getSavedUserName() {
    return _authBox.get(_userNameKey);
  }
  
  // Clear user session
  static Future<void> clearUserSession() async {
    await _authBox.delete(_userIdKey);
    await _authBox.delete(_userEmailKey);
    await _authBox.delete(_userNameKey);
    await _authBox.put(_isLoggedInKey, false);
  }
  
  // Clear all auth data
  static Future<void> clearAll() async {
    await _authBox.clear();
  }
}
