import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      },
      'tr': {
        'app_name': 'GideriVar',
        'login': 'Giriş Yap',
        'register': 'Kayıt Ol',
        'email': 'E-posta',
        'password': 'Şifre',
      },
    };

    return translations[_currentLanguage]?[key] ?? key;
  }
}
