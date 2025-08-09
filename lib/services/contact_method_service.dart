import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/contact_method.dart';

class ContactMethodService {
  static Future<bool> launchContactMethod(ContactMethod method) async {
    try {
      final Uri uri = _buildUri(method);
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error launching contact method: $e');
      return false;
    }
  }

  static Uri _buildUri(ContactMethod method) {
    switch (method.type) {
      case ContactMethodType.phone:
        return Uri(scheme: 'tel', path: method.value);
      
      case ContactMethodType.whatsapp:
        // WhatsApp formatı: https://wa.me/905551234567
        String phoneNumber = method.value.replaceAll(RegExp(r'[^\d+]'), '');
        if (phoneNumber.startsWith('0')) {
          phoneNumber = '+90${phoneNumber.substring(1)}';
        }
        if (!phoneNumber.startsWith('+')) {
          phoneNumber = '+90$phoneNumber';
        }
        return Uri.parse('https://wa.me/${phoneNumber.replaceAll('+', '')}');
      
      case ContactMethodType.email:
        return Uri(scheme: 'mailto', path: method.value);
      
      case ContactMethodType.instagram:
        // Instagram deep link
        String username = method.value.replaceAll('@', '');
        return Uri.parse('https://instagram.com/$username');
      
      case ContactMethodType.inAppMessage:
        // Uygulama içi mesajlaşma için özel scheme
        return Uri(scheme: 'giderivar', path: 'message', query: 'userId=${method.value}');
    }
  }

  static String getContactDisplayText(ContactMethod method) {
    switch (method.type) {
      case ContactMethodType.phone:
        return '${method.displayName} ile Ara';
      case ContactMethodType.whatsapp:
        return 'WhatsApp ile Mesaj Gönder';
      case ContactMethodType.email:
        return 'E-mail Gönder';
      case ContactMethodType.instagram:
        return 'Instagram\'da Mesaj At';
      case ContactMethodType.inAppMessage:
        return 'Uygulama İçi Mesaj Gönder';
    }
  }

  static String getContactActionText(ContactMethod method) {
    switch (method.type) {
      case ContactMethodType.phone:
        return 'Aranıyor...';
      case ContactMethodType.whatsapp:
        return 'WhatsApp açılıyor...';
      case ContactMethodType.email:
        return 'E-mail uygulaması açılıyor...';
      case ContactMethodType.instagram:
        return 'Instagram açılıyor...';
      case ContactMethodType.inAppMessage:
        return 'Mesaj ekranına yönlendiriliyor...';
    }
  }

  /// Telefon numarasını formatlar (Türkiye formatı)
  static String formatPhoneNumber(String phone) {
    // Sadece rakamları al
    String digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digits.length == 11 && digits.startsWith('0')) {
      // 05551234567 -> +90 555 123 45 67
      return '+90 ${digits.substring(1, 4)} ${digits.substring(4, 7)} ${digits.substring(7, 9)} ${digits.substring(9)}';
    } else if (digits.length == 10) {
      // 5551234567 -> +90 555 123 45 67
      return '+90 ${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6, 8)} ${digits.substring(8)}';
    } else if (digits.length == 13 && digits.startsWith('90')) {
      // 905551234567 -> +90 555 123 45 67
      return '+90 ${digits.substring(2, 5)} ${digits.substring(5, 8)} ${digits.substring(8, 10)} ${digits.substring(10)}';
    }
    
    return phone; // Formatlanmamış halini döndür
  }

  /// Instagram kullanıcı adını formatlar
  static String formatInstagramUsername(String username) {
    username = username.trim();
    if (!username.startsWith('@')) {
      username = '@$username';
    }
    return username;
  }

  /// E-mail adresini doğrular
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  /// Telefon numarasını doğrular (Türkiye formatı)
  static bool isValidPhoneNumber(String phone) {
    String digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Türk telefon numarası kontrolü
    if (digits.length == 11 && digits.startsWith('0')) {
      return digits.startsWith('05'); // Cep telefonu
    } else if (digits.length == 10) {
      return digits.startsWith('5'); // Cep telefonu (başında 0 yok)
    } else if (digits.length == 13 && digits.startsWith('90')) {
      return digits.substring(2).startsWith('5'); // +90 ile başlayan
    }
    
    return false;
  }

  /// Instagram kullanıcı adını doğrular
  static bool isValidInstagramUsername(String username) {
    username = username.replaceAll('@', '');
    return RegExp(r'^[a-zA-Z0-9._]{1,30}$').hasMatch(username);
  }
}
