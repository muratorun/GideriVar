import 'package:flutter/material.dart';

enum ContactMethodType {
  phone,
  whatsapp,
  email,
  instagram,
  inAppMessage // Uygulama içi mesajlaşma eklendi
}

class ContactMethod {
  final ContactMethodType type;
  final String value;
  final bool isVerified;
  final DateTime? createdAt;

  const ContactMethod({
    required this.type,
    required this.value,
    this.isVerified = false,
    this.createdAt,
  });

  // Display names for UI
  String get displayName {
    switch (type) {
      case ContactMethodType.phone:
        return 'Telefon';
      case ContactMethodType.whatsapp:
        return 'WhatsApp';
      case ContactMethodType.email:
        return 'E-mail';
      case ContactMethodType.instagram:
        return 'Instagram';
      case ContactMethodType.inAppMessage:
        return 'Uygulama İçi Mesaj';
    }
  }

  // Icons for UI
  IconData get icon {
    switch (type) {
      case ContactMethodType.phone:
        return Icons.phone;
      case ContactMethodType.whatsapp:
        return Icons.chat;
      case ContactMethodType.email:
        return Icons.email;
      case ContactMethodType.instagram:
        return Icons.camera_alt;
      case ContactMethodType.inAppMessage:
        return Icons.message;
    }
  }

  // Colors for UI
  Color get color {
    switch (type) {
      case ContactMethodType.phone:
        return const Color(0xFF2196F3);
      case ContactMethodType.whatsapp:
        return const Color(0xFF25D366);
      case ContactMethodType.email:
        return const Color(0xFFFF5722);
      case ContactMethodType.instagram:
        return const Color(0xFFE4405F);
      case ContactMethodType.inAppMessage:
        return const Color(0xFF9C27B0); // Mor renk
    }
  }

  // Input validation patterns
  String? get validationPattern {
    switch (type) {
      case ContactMethodType.phone:
        return r'^[\+]?[0-9]{10,15}$';
      case ContactMethodType.whatsapp:
        return r'^[\+]?[0-9]{10,15}$';
      case ContactMethodType.email:
        return r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
      case ContactMethodType.instagram:
        return r'^[a-zA-Z0-9._]{1,30}$';
      case ContactMethodType.inAppMessage:
        return null; // Uygulama içi mesaj için doğrulama yok
    }
  }

  // Input hints
  String get hintText {
    switch (type) {
      case ContactMethodType.phone:
        return '+90 5XX XXX XX XX';
      case ContactMethodType.whatsapp:
        return '+90 5XX XXX XX XX';
      case ContactMethodType.email:
        return 'ornek@email.com';
      case ContactMethodType.instagram:
        return 'kullaniciadi';
      case ContactMethodType.inAppMessage:
        return 'Uygulama içi mesajlaşma açık';
    }
  }

  // Input prefixes
  String? get prefix {
    switch (type) {
      case ContactMethodType.instagram:
        return '@';
      default:
        return null;
    }
  }

  // Keyboard types
  TextInputType get keyboardType {
    switch (type) {
      case ContactMethodType.phone:
      case ContactMethodType.whatsapp:
        return TextInputType.phone;
      case ContactMethodType.email:
        return TextInputType.emailAddress;
      case ContactMethodType.instagram:
        return TextInputType.text;
      case ContactMethodType.inAppMessage:
        return TextInputType.none; // Giriş yok
    }
  }

  // Validation function
  String? validate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '$displayName bilgisi gereklidir';
    }

    final pattern = validationPattern;
    if (pattern != null) {
      final regex = RegExp(pattern);
      if (!regex.hasMatch(value.trim())) {
        switch (type) {
          case ContactMethodType.phone:
          case ContactMethodType.whatsapp:
            return 'Geçerli bir telefon numarası giriniz';
          case ContactMethodType.email:
            return 'Geçerli bir e-mail adresi giriniz';
          case ContactMethodType.instagram:
            return 'Geçerli bir Instagram kullanıcı adı giriniz';
          case ContactMethodType.inAppMessage:
            return null; // Uygulama içi mesaj için hata yok
        }
      }
    }

    return null;
  }

  // Format value for display
  String get formattedValue {
    switch (type) {
      case ContactMethodType.instagram:
        return prefix != null ? '$prefix$value' : value;
      default:
        return value;
    }
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'type': type.toString().split('.').last,
      'value': value,
      'isVerified': isVerified,
      'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }

  // Create from Map (Firestore)
  factory ContactMethod.fromMap(Map<String, dynamic> map) {
    return ContactMethod(
      type: ContactMethodType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
      ),
      value: map['value'] ?? '',
      isVerified: map['isVerified'] ?? false,
      createdAt: map['createdAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : null,
    );
  }

  // Copy with
  ContactMethod copyWith({
    ContactMethodType? type,
    String? value,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return ContactMethod(
      type: type ?? this.type,
      value: value ?? this.value,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContactMethod &&
        other.type == type &&
        other.value == value;
  }

  @override
  int get hashCode => type.hashCode ^ value.hashCode;

  @override
  String toString() {
    return 'ContactMethod(type: $type, value: $value, isVerified: $isVerified)';
  }
}
