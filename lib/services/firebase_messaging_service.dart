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
  Future<
    void
  >
  initialize() async {
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

      if (settings.authorizationStatus ==
          AuthorizationStatus.authorized) {
        debugPrint(
          'Firebase: User granted permission',
        );
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        debugPrint(
          'Firebase: User granted provisional permission',
        );
      } else {
        debugPrint(
          'Firebase: User declined or has not accepted permission',
        );
      }

      // FCM token'ını al
      _fcmToken = await _firebaseMessaging.getToken();
      debugPrint(
        'Firebase FCM Token: $_fcmToken',
      );

      // Token yenilendiğinde dinle
      _firebaseMessaging.onTokenRefresh.listen(
        (
          newToken,
        ) {
          _fcmToken = newToken;
          debugPrint(
            'Firebase FCM Token refreshed: $newToken',
          );
          // Burada token'ı sunucuya gönderebilirsiniz
          _sendTokenToServer(
            newToken,
          );
        },
      );

      // Foreground mesajları dinle
      FirebaseMessaging.onMessage.listen(
        (
          RemoteMessage message,
        ) {
          debugPrint(
            'Firebase: Foreground message received: ${message.messageId}',
          );
          _handleForegroundMessage(
            message,
          );
        },
      );

      // App açıldığında mesaj kontrolü
      FirebaseMessaging.onMessageOpenedApp.listen(
        (
          RemoteMessage message,
        ) {
          debugPrint(
            'Firebase: App opened from notification: ${message.messageId}',
          );
          _handleMessageOpenedApp(
            message,
          );
        },
      );

      // App kapalı durumdayken mesaj kontrolü
      RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage !=
          null) {
        debugPrint(
          'Firebase: App launched from notification: ${initialMessage.messageId}',
        );
        _handleInitialMessage(
          initialMessage,
        );
      }
    } catch (
      e
    ) {
      debugPrint(
        'Firebase Messaging initialization error: $e',
      );
    }
  }

  // Foreground message handler
  void _handleForegroundMessage(
    RemoteMessage message,
  ) {
    debugPrint(
      'Firebase: Handling foreground message',
    );
    debugPrint(
      'Title: ${message.notification?.title}',
    );
    debugPrint(
      'Body: ${message.notification?.body}',
    );
    debugPrint(
      'Data: ${message.data}',
    );

    // Burada kendi notification UI'ını gösterebilirsiniz
    // Örneğin: ScaffoldMessenger ile snackbar göstermek
  }

  // Message opened app handler
  void _handleMessageOpenedApp(
    RemoteMessage message,
  ) {
    debugPrint(
      'Firebase: Handling message opened app',
    );
    debugPrint(
      'Message data: ${message.data}',
    );

    // Burada belirli bir sayfaya navigation yapabilirsiniz
    // Örneğin: Navigator.pushNamed(context, '/product-detail', arguments: message.data);
  }

  // Initial message handler (app was terminated)
  void _handleInitialMessage(
    RemoteMessage message,
  ) {
    debugPrint(
      'Firebase: Handling initial message',
    );
    debugPrint(
      'Message data: ${message.data}',
    );

    // App kapalıyken notification'a tıklanarak açıldığında
    // belirli bir sayfaya yönlendirme yapabilirsiniz
  }

  // Token'ı sunucuya gönder
  void _sendTokenToServer(
    String token,
  ) {
    debugPrint(
      'Firebase: Sending token to server: $token',
    );

    // Burada kendi backend'inize token'ı gönderebilirsiniz
    // Örnek:
    // ApiService.sendFCMToken(token);
  }

  // Belirli bir topic'e subscribe ol
  Future<
    void
  >
  subscribeToTopic(
    String topic,
  ) async {
    try {
      await _firebaseMessaging.subscribeToTopic(
        topic,
      );
      debugPrint(
        'Firebase: Subscribed to topic: $topic',
      );
    } catch (
      e
    ) {
      debugPrint(
        'Firebase: Error subscribing to topic $topic: $e',
      );
    }
  }

  // Topic'ten unsubscribe ol
  Future<
    void
  >
  unsubscribeFromTopic(
    String topic,
  ) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(
        topic,
      );
      debugPrint(
        'Firebase: Unsubscribed from topic: $topic',
      );
    } catch (
      e
    ) {
      debugPrint(
        'Firebase: Error unsubscribing from topic $topic: $e',
      );
    }
  }

  // Notification badge'i temizle (iOS)
  Future<
    void
  >
  clearBadge() async {
    try {
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint(
        'Firebase: Badge cleared',
      );
    } catch (
      e
    ) {
      debugPrint(
        'Firebase: Error clearing badge: $e',
      );
    }
  }

  // Service'i dispose et
  void dispose() {
    debugPrint(
      'Firebase: Messaging service disposed',
    );
  }
}
