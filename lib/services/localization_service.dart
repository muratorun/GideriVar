import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/settings_model.dart';
import '../utils/constants.dart';

class LocalizationService extends ChangeNotifier {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  late Box<SettingsModel> _settingsBox;
  SettingsModel? _settings;
  String _currentLanguage = AppConstants.defaultLanguage;

  String get currentLanguage => _currentLanguage;
  SettingsModel? get settings => _settings;

  // Initialize Hive and load settings
  Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(SettingsModelAdapter());
    }

    _settingsBox = await Hive.openBox<SettingsModel>('settings');
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    _settings = _settingsBox.get('user_settings');
    
    if (_settings == null) {
      // First time - detect device language
      final deviceLocale = PlatformDispatcher.instance.locale.languageCode;
      final detectedLanguage = _detectSupportedLanguage(deviceLocale);
      
      _settings = SettingsModel(language: detectedLanguage);
      await _saveSettings();
    }
    
    _currentLanguage = _settings!.language;
    notifyListeners();
  }

  String _detectSupportedLanguage(String deviceLanguage) {
    if (AppConstants.supportedLanguages.contains(deviceLanguage)) {
      return deviceLanguage;
    }
    return AppConstants.defaultLanguage; // Fallback to English
  }

  Future<void> changeLanguage(String languageCode) async {
    if (AppConstants.supportedLanguages.contains(languageCode)) {
      _currentLanguage = languageCode;
      _settings = _settings!.copyWith(language: languageCode);
      await _saveSettings();
      notifyListeners();
    }
  }

  Future<void> updateSettings(SettingsModel newSettings) async {
    _settings = newSettings;
    _currentLanguage = newSettings.language;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    if (_settings != null) {
      await _settingsBox.put('user_settings', _settings!);
    }
  }

  // Get localized text
  String getText(String key) {
    final translations = AppConstants.uiTranslations[_currentLanguage];
    return translations?[key] ?? AppConstants.uiTranslations['en']?[key] ?? key;
  }

  // Get localized category
  String getCategory(String category) {
    final translations = AppConstants.categoryTranslations[_currentLanguage];
    return translations?[category] ?? AppConstants.categoryTranslations['en']?[category] ?? category;
  }

  // Get language display name
  String getLanguageName(String languageCode) {
    return AppConstants.languageNames[languageCode] ?? languageCode;
  }

  // Get current locale
  Locale get currentLocale => Locale(_currentLanguage);

  // Get all supported locales
  List<Locale> get supportedLocales {
    return AppConstants.supportedLanguages.map((lang) => Locale(lang)).toList();
  }

  // Save last selected location
  Future<void> saveLastLocation(String? country, String? city) async {
    if (_settings != null) {
      _settings = _settings!.copyWith(
        lastSelectedCountry: country,
        lastSelectedCity: city,
      );
      await _saveSettings();
    }
  }

  // Toggle dark mode
  Future<void> toggleDarkMode() async {
    if (_settings != null) {
      _settings = _settings!.copyWith(isDarkMode: !_settings!.isDarkMode);
      await _saveSettings();
      notifyListeners();
    }
  }

  // Toggle notifications
  Future<void> toggleNotifications() async {
    if (_settings != null) {
      _settings = _settings!.copyWith(notificationsEnabled: !_settings!.notificationsEnabled);
      await _saveSettings();
      notifyListeners();
    }
  }

  // Toggle sound
  Future<void> toggleSound() async {
    if (_settings != null) {
      _settings = _settings!.copyWith(soundEnabled: !_settings!.soundEnabled);
      await _saveSettings();
      notifyListeners();
    }
  }

  // Close Hive boxes
  @override
  Future<void> dispose() async {
    await _settingsBox.close();
    super.dispose();
  }
}

// Extension for easy access in widgets
extension LocalizationContext on BuildContext {
  String tr(String key) => LocalizationService().getText(key);
  String category(String category) => LocalizationService().getCategory(category);
}
