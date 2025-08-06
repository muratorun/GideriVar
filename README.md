# GideriVar

Gerçek Firebase projesi ve production AdMob entegrasyonu ile çalışan Flutter uygulaması.

## Önemli Not - Google Sign-In

Google Sign-In özelliği şu anda iOS dependency conflict nedeniyle geçici olarak devre dışı bırakılmıştır:

**Sorun:** 
- Firebase SDK (GoogleUtilities ~7.12) ile Google Sign-In iOS SDK (GoogleUtilities ~8.0) arasında version conflict
- CocoaPods bu versiyonları çözemiyor

**Çözüm Bekliyor:**
1. `pubspec.yaml`'da `google_sign_in` dependency'si yorum satırında
2. `auth_service.dart`'ta Google Sign-In kodu yorum satırında ve aktif hale getirme talimatları mevcut
3. iOS OAuth Client ID'si zaten Info.plist'te yapılandırılmış durumda

**Nasıl Aktif Hale Getirilir:**
1. `pubspec.yaml`'da `google_sign_in: ^5.4.2` satırının yorum işaretini kaldır
2. `auth_service.dart`'ta import satırının yorum işaretini kaldır
3. `signInWithGoogle()` metodundaki TODO yorumunu takip et
4. `flutter pub get` ve `cd ios && pod install` çalıştır

## Mevcut Özellikler

- ✅ Email/Password Authentication (Firebase Auth)
- ✅ Firebase Firestore Database  
- ✅ Firebase Storage
- ✅ Firebase Messaging (Push Notifications)
- ✅ Google AdMob (Production)
- ✅ Hive Local Storage
- ✅ Provider State Management
- ⏳ Google Sign-In (Android çalışıyor, iOS dependency conflict)

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
