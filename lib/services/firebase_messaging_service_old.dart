import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
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
        debugPrint('User granted permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('User granted provisional permission');
      } else {
        debugPrint('User declined or has not accepted permission');
      }

      // FCM token'ını al
      _fcmToken = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $_fcmToken');

      // Token yenilendiğinde dinle
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('FCM Token refreshed: $newToken');
        // Burada token'ı sunucuya gönderebilirsiniz
      });

      // Local notifications'ı başlat
      await _initializeLocalNotifications();

      // Message handler'ları ayarla
      _setupMessageHandlers();

      debugPrint('Firebase Messaging initialized successfully');
    } catch (e) {
      debugPrint('Firebase Messaging initialization error: $e');
    }
  }

  // Local notifications'ı başlat
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Android notification channel oluştur
    const androidChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  // Message handler'ları ayarla
  void _setupMessageHandlers() {
    // Uygulama açıkken gelen mesajlar
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Uygulama kapalıyken notification'a tıklanınca
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Uygulama tamamen kapalıyken notification'a tıklanınca
    _firebaseMessaging.getInitialMessage().then((message) {
      if (message != null) {
        _handleMessageOpenedApp(message);
      }
    });
  }

  // Uygulama açıkken gelen mesajları işle
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Received foreground message: ${message.messageId}');
    
    // Local notification göster
    await _showLocalNotification(message);
  }

  // Notification'a tıklandığında
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('Message opened app: ${message.messageId}');
    
    // Burada mesaja göre uygun sayfaya yönlendirme yapabilirsiniz
    final data = message.data;
    if (data.containsKey('route')) {
      // Navigator ile uygun sayfaya git
      debugPrint('Navigate to: ${data['route']}');
    }
  }

  // Local notification göster
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: false,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'GideriVar',
      message.notification?.body ?? 'Yeni bildirim',
      details,
      payload: message.data.toString(),
    );
  }

  // Notification'a tıklandığında
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Burada notification payload'ına göre işlem yapabilirsiniz
  }

  // Belirli topic'e abone ol
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic $topic: $e');
    }
  }

  // Topic aboneliğinden çık
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic $topic: $e');
    }
  }

  // FCM token'ını sunucuya gönder
  Future<void> sendTokenToServer(String userId) async {
    if (_fcmToken != null) {
      try {
        // Burada token'ı backend'e gönderme kodunu yazabilirsiniz
        debugPrint('Sending FCM token to server for user: $userId');
        debugPrint('Token: $_fcmToken');
        
        // Örnek: HTTP POST request
        // await http.post(
        //   Uri.parse('your-api-endpoint/fcm-token'),
        //   body: {
        //     'userId': userId,
        //     'fcmToken': _fcmToken,
        //   },
        // );
      } catch (e) {
        debugPrint('Error sending token to server: $e');
      }
    }
  }
}
