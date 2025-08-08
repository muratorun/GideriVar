import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';
import 'services/localization_service.dart';
import 'services/firebase_messaging_service.dart';
import 'services/ads_service.dart';
import 'services/auth_persistence_service.dart';
import 'utils/constants.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_screen.dart';
import 'screens/add_product_screen.dart';

// Firebase background message handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Background message received: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Hive'ı initialize et
  try {
    await Hive.initFlutter();
    await AuthPersistenceService.initialize();
    debugPrint('Hive and AuthPersistenceService initialized successfully');
  } catch (e) {
    debugPrint('Hive initialization failed: $e');
  }
  
  // Firebase'i initialize et
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('Firebase initialized successfully');
    } else {
      debugPrint('Firebase already initialized');
    }
    
    // Firebase Messaging background handler - sadece background handler'ı kaydet
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    debugPrint('Firebase background message handler registered');
    
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
  
  // Google Sign-In Production konfigürasyonu
  debugPrint('Google Sign-In 6.x ready for production');
  
  // Google Sign-In 7.x Android için serverClientId initialize et
  try {
    await GoogleSignIn.instance.initialize(
      serverClientId: '146943865377-51aaimcoq5qt444t6rhckhcgs6hpofj5.apps.googleusercontent.com', // Web Client ID from google-services.json
    );
    debugPrint('Google Sign-In 7.x initialized with serverClientId for Android');
  } catch (e) {
    debugPrint('Google Sign-In 7.x initialization failed: $e');
  }

  // Google Mobile Ads'ı initialize et
  try {
    await AdsService.instance.initialize();
    debugPrint('Google Mobile Ads initialized successfully');
  } catch (e) {
    debugPrint('Ads initialization failed: $e');
  }
  
  // LocalizationService'i initialize et
  try {
    await LocalizationService().initialize();
    debugPrint('LocalizationService initialized successfully');
  } catch (e) {
    debugPrint('LocalizationService initialization failed: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Firebase Messaging'i widget tree hazır olduktan sonra başlat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFirebaseMessaging();
    });
  }

  Future<void> _initializeFirebaseMessaging() async {
    try {
      // Kısa bir gecikme ile APNS token'ın hazır olmasını bekle
      await Future.delayed(const Duration(seconds: 2));
      
      final messagingService = FirebaseMessagingService();
      await messagingService.initialize();
      debugPrint('Firebase Messaging initialized successfully');
    } catch (e) {
      debugPrint('Firebase Messaging initialization failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: LocalizationService(),
        ),
        // Firebase Messaging Service
        Provider<FirebaseMessagingService>(
          create: (_) => FirebaseMessagingService(),
        ),
        // Ads Service
        Provider<AdsService>(
          create: (_) => AdsService.instance,
        ),
      ],
      child: Consumer<LocalizationService>(
        builder: (context, localizationService, child) {
          return MaterialApp(
            title: 'GideriVar',
            debugShowCheckedModeBanner: false,
            
            // Localization configuration
            locale: localizationService.currentLocale,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: localizationService.supportedLocales,
            
            // Theme configuration
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              fontFamily: 'Roboto',
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                foregroundColor: AppColors.primary,
              ),
            ),
            
            // Navigation configuration
            initialRoute: AuthPersistenceService.isUserLoggedIn() ? '/main' : '/',
            routes: {
              '/': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/main': (context) => const MainScreen(),
              '/add-product': (context) => const AddProductScreen(),
            },
          );
        },
      ),
    );
  }
}
