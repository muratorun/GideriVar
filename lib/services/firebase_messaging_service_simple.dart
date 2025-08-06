import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  // Firebase Messaging'i başlat
  Future<void> initialize() async {
    try {
      // Notification izinlerini iste
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('Firebase: User granted permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('Firebase: User granted provisional permission');
      } else {
        debugPrint('Firebase: User declined or has not accepted permission');
      }

      // FCM token'ını al
      _fcmToken = await _firebaseMessaging.getToken();
      debugPrint('Firebase FCM Token: $_fcmToken');

      // Token yenilendiğinde dinle
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('Firebase FCM Token refreshed: $newToken');
        // Burada token'ı sunucuya gönderebilirsiniz
      });

      // Foreground mesajları dinle
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Firebase Foreground message received: ${message.messageId}');
        debugPrint('Title: ${message.notification?.title}');
        debugPrint('Body: ${message.notification?.body}');
        debugPrint('Data: ${message.data}');
      });

      // Uygulama açık değilken mesaja tıklandığında
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('Firebase Message clicked: ${message.messageId}');
        debugPrint('Data: ${message.data}');
        // Burada belirli bir sayfaya yönlendirme yapabilirsiniz
      });

      // Uygulama tamamen kapalıyken mesaja tıklandığında
      RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('Firebase App launched from notification: ${initialMessage.messageId}');
        debugPrint('Data: ${initialMessage.data}');
        // Burada belirli bir sayfaya yönlendirme yapabilirsiniz
      }

    } catch (e) {
      debugPrint('Firebase Messaging initialization error: $e');
    }
  }

  // FCM token'ını yenile
  Future<String?> refreshToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _fcmToken = await _firebaseMessaging.getToken();
      debugPrint('Firebase FCM Token refreshed: $_fcmToken');
      return _fcmToken;
    } catch (e) {
      debugPrint('Firebase Token refresh error: $e');
      return null;
    }
  }

  // Belirli bir topic'e subscribe ol
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Firebase Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Firebase Subscribe error: $e');
    }
  }

  // Topic'ten unsubscribe ol
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Firebase Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Firebase Unsubscribe error: $e');
    }
  }
}
