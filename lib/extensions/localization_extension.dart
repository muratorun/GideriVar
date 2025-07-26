import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/localization_service.dart';

extension LocalizationExtension on BuildContext {
  /// Get localized UI text
  String tr(String key) {
    return Provider.of<LocalizationService>(this, listen: false).getText(key);
  }

  /// Get localized category text
  String category(String key) {
    return Provider.of<LocalizationService>(this, listen: false).getCategory(key);
  }

  /// Get current language code
  String get currentLanguage {
    return Provider.of<LocalizationService>(this, listen: false).currentLanguage;
  }

  /// Get current locale
  Locale get currentLocale {
    return Provider.of<LocalizationService>(this, listen: false).currentLocale;
  }

  /// Check if current language is RTL
  bool get isRTL {
    final languageCode = currentLanguage;
    return ['ar', 'fa', 'he', 'ur'].contains(languageCode);
  }
}
