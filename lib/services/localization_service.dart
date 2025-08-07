import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';

class LocalizationService extends ChangeNotifier {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  String _currentLanguage = AppConstants.defaultLanguage;
  
  String get currentLanguage => _currentLanguage;

  // Basit initialize - SharedPreferences kullan
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceLocale = PlatformDispatcher.instance.locale.languageCode;
      final detectedLanguage = _detectSupportedLanguage(deviceLocale);
      
      _currentLanguage = prefs.getString('language') ?? detectedLanguage;
      await prefs.setString('language', _currentLanguage);
      notifyListeners();
    } catch (e) {
      debugPrint('LocalizationService init error: $e');
      _currentLanguage = AppConstants.defaultLanguage;
    }
  }

  String _detectSupportedLanguage(String deviceLanguage) {
    if (AppConstants.supportedLanguages.contains(deviceLanguage)) {
      return deviceLanguage;
    }
    return AppConstants.defaultLanguage;
  }

  Future<void> changeLanguage(String languageCode) async {
    if (AppConstants.supportedLanguages.contains(languageCode)) {
      _currentLanguage = languageCode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', languageCode);
      notifyListeners();
    }
  }

  // Locale getter
  Locale get currentLocale {
    return Locale(_currentLanguage);
  }

  // Supported locales
  List<Locale> get supportedLocales {
    return AppConstants.supportedLanguages
        .map((language) => Locale(language))
        .toList();
  }

  // Localized text methods (basit implementasyon)
  String translate(String key) {
    // Basit çeviri - gerçek uygulamada localization dosyalarından gelecek
    final translations = {
      'en': {
        'app_name': 'GideriVar',
        'login': 'Login',
        'register': 'Register',
        'email': 'Email',
        'password': 'Password',
        'settings': 'Settings',
        'language': 'Language',
        'change_language': 'Change Language',
        'edit_profile': 'Edit Profile',
        'feature_coming_soon': 'This feature is coming soon',
        'notifications': 'Notifications',
        'help': 'Help',
        'logout': 'Logout',
        'logout_confirmation': 'Are you sure you want to logout?',
        'cancel': 'Cancel',
        'select_language': 'Select Language',
      },
      'tr': {
        'app_name': 'GideriVar',
        'login': 'Giriş Yap',
        'register': 'Kayıt Ol',
        'email': 'E-posta',
        'password': 'Şifre',
        'settings': 'Ayarlar',
        'language': 'Dil',
        'change_language': 'Dil Değiştir',
        'edit_profile': 'Profili Düzenle',
        'feature_coming_soon': 'Bu özellik yakında gelecek',
        'notifications': 'Bildirimler',
        'help': 'Yardım',
        'logout': 'Çıkış Yap',
        'logout_confirmation': 'Çıkış yapmak istediğinizden emin misiniz?',
        'cancel': 'İptal',
        'select_language': 'Dil Seçin',
      },
    };

    return translations[_currentLanguage]?[key] ?? key;
  }

  // Extension metodları için ek metotlar
  String getText(String key) {
    return translate(key);
  }

  String getCategory(String key) {
    final categories = {
      'en': {
        'electronics': 'Electronics',
        'clothing': 'Clothing',
        'home': 'Home & Garden',
        'sports': 'Sports',
        'books': 'Books',
        'toys': 'Toys',
        'automotive': 'Automotive',
        'other': 'Other',
      },
      'tr': {
        'electronics': 'Elektronik',
        'clothing': 'Giyim',
        'home': 'Ev & Bahçe',
        'sports': 'Spor',
        'books': 'Kitap',
        'toys': 'Oyuncak',
        'automotive': 'Otomotiv',
        'other': 'Diğer',
      },
    };
    return categories[_currentLanguage]?[key] ?? key;
  }
}

// Extension method for easy access from BuildContext
extension LocalizationExtension on BuildContext {
  String tr(String key) {
    try {
      final localizationService = Provider.of<LocalizationService>(this, listen: false);
      return localizationService.translate(key);
    } catch (e) {
      debugPrint('Translation error for key "$key": $e');
      return key; // Return key as fallback
    }
  }
}
