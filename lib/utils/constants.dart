import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

// App Colors
class AppColors {
  static const Color primary = Color(0xFF2E7D32);
  static const Color secondary = Color(0xFF4CAF50);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFD32F2F);
}

class AppConstants {
  // Project Information
  static const String projectName = 'GideriVar';
  
  // Business Model Parametrik Değerler - kolayca değiştirilebilir
  static const int defaultPurchaseLimit = 1;
  static const int premiumPurchaseLimit = 5;
  static const bool requireAdForContactInfo = true;
  
  // Firebase Collection Names
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String purchasesCollection = 'purchases';
  static const String adViewsCollection = 'ad_views';
  static const String locationsCollection = 'locations';
  
  // Contact Method Types
  static const List<String> contactMethods = [
    'phone',
    'whatsapp', 
    'email',
    'instagram'
  ];
  
  // Contact Method Display Names (localization için)
  static const Map<String, String> contactMethodNames = {
    'phone': 'Telefon',
    'whatsapp': 'WhatsApp',
    'email': 'E-mail',
    'instagram': 'Instagram'
  };
  
  // Location Settings
  static const bool useOnlineLocationService = true;
  static const String defaultCountry = 'Global';
  static const String defaultCity = 'All Cities';
  
  // API Keys (platform specific)
  static const String rapidApiKey = 'ab0a109787mshe1e3813ee310877p17e3dajsn319ed0cd58a7';
  
  // Google Maps API Keys (platform specific)
  static const String googleMapsApiKeyAndroid = 'AIzaSyCtYdc_5JzDvmuJfpE7lTyi7g1S1BzVjEQ';
  static const String googleMapsApiKeyIOS = 'AIzaSyD8cXSvRf1RGyDMjI_kAK6AVNHeqSImjwc';
  static const String googleMapsApiKeyWeb = 'AIzaSyBI5UBPgq_85t-WuZotwqDzAOUmteBNXJk';
  
  // Platform detector için Google Maps API Key
  static String get googleMapsApiKey {
    // Web için
    if (kIsWeb) {
      return googleMapsApiKeyWeb;
    }
    // Mobile platforms için
    else {
      try {
        if (Platform.isIOS) {
          return googleMapsApiKeyIOS;
        } else {
          return googleMapsApiKeyAndroid;
        }
      } catch (e) {
        // Fallback olarak Android key
        return googleMapsApiKeyAndroid;
      }
    }
  }
  
  // Google Maps API URLs
  static const String geocodingBaseUrl = 'https://maps.googleapis.com/maps/api/geocode/json';
  static const String placesBaseUrl = 'https://maps.googleapis.com/maps/api/place';
  static const String directionsBaseUrl = 'https://maps.googleapis.com/maps/api/directions/json';
  
  // Fallback regions (API erişimi yoksa)
  static const List<String> fallbackRegions = [
    'Global',
    'North America',
    'Europe', 
    'Asia',
    'South America',
    'Africa',
    'Oceania',
    'Middle East',
  ];
  
  // Global Categories (multi-language support ready)
  static const List<String> categories = [
    'Electronics',
    'Fashion & Accessories', 
    'Home & Garden',
    'Sports & Outdoors',
    'Books & Media',
    'Baby & Kids',
    'Beauty & Personal Care',
    'Automotive',
    'Furniture',
    'Tools & Hardware',
    'Toys & Games',
    'Health & Wellness',
    'Art & Crafts',
    'Music & Instruments',
    'Other'
  ];

  // Supported Languages
  static const List<String> supportedLanguages = ['tr', 'en', 'de', 'zh', 'ru', 'ja'];
  static const String defaultLanguage = 'en';
  
  // Language Display Names
  static const Map<String, String> languageNames = {
    'tr': 'Türkçe',
    'en': 'English', 
    'de': 'Deutsch',
    'zh': '中文',
    'ru': 'Русский',
    'ja': '日本語',
  };

  // Multilingual category mappings (genişletildi)
  static const Map<String, Map<String, String>> categoryTranslations = {
    'en': {
      'Electronics': 'Electronics',
      'Fashion & Accessories': 'Fashion & Accessories',
      'Home & Garden': 'Home & Garden',
      'Sports & Outdoors': 'Sports & Outdoors',
      'Books & Media': 'Books & Media',
      'Baby & Kids': 'Baby & Kids',
      'Beauty & Personal Care': 'Beauty & Personal Care',
      'Automotive': 'Automotive',
      'Furniture': 'Furniture',
      'Tools & Hardware': 'Tools & Hardware',
      'Toys & Games': 'Toys & Games',
      'Health & Wellness': 'Health & Wellness',
      'Art & Crafts': 'Art & Crafts',
      'Music & Instruments': 'Music & Instruments',
      'Other': 'Other',
    },
    'tr': {
      'Electronics': 'Elektronik',
      'Fashion & Accessories': 'Giyim & Aksesuar',
      'Home & Garden': 'Ev & Bahçe', 
      'Sports & Outdoors': 'Spor & Outdoor',
      'Books & Media': 'Kitap & Medya',
      'Baby & Kids': 'Bebê & Çocuk',
      'Beauty & Personal Care': 'Kozmetik & Kişisel Bakım',
      'Automotive': 'Otomotiv',
      'Furniture': 'Mobilya',
      'Tools & Hardware': 'Alet & Donanım',
      'Toys & Games': 'Oyuncak & Oyun',
      'Health & Wellness': 'Sağlık & Wellness',
      'Art & Crafts': 'Sanat & El Sanatları',
      'Music & Instruments': 'Müzik & Enstrüman',
      'Other': 'Diğer',
    },
    'de': {
      'Electronics': 'Elektronik',
      'Fashion & Accessories': 'Mode & Accessoires',
      'Home & Garden': 'Haus & Garten',
      'Sports & Outdoors': 'Sport & Outdoor',
      'Books & Media': 'Bücher & Medien',
      'Baby & Kids': 'Baby & Kinder',
      'Beauty & Personal Care': 'Schönheit & Körperpflege',
      'Automotive': 'Automobil',
      'Furniture': 'Möbel',
      'Tools & Hardware': 'Werkzeuge & Hardware',
      'Toys & Games': 'Spielzeug & Spiele',
      'Health & Wellness': 'Gesundheit & Wellness',
      'Art & Crafts': 'Kunst & Handwerk',
      'Music & Instruments': 'Musik & Instrumente',
      'Other': 'Andere',
    },
    'zh': {
      'Electronics': '电子产品',
      'Fashion & Accessories': '时尚配饰',
      'Home & Garden': '家居园艺',
      'Sports & Outdoors': '运动户外',
      'Books & Media': '图书媒体',
      'Baby & Kids': '母婴儿童',
      'Beauty & Personal Care': '美容个护',
      'Automotive': '汽车用品',
      'Furniture': '家具',
      'Tools & Hardware': '工具五金',
      'Toys & Games': '玩具游戏',
      'Health & Wellness': '健康保健',
      'Art & Crafts': '艺术手工',
      'Music & Instruments': '音乐乐器',
      'Other': '其他',
    },
    'ru': {
      'Electronics': 'Электроника',
      'Fashion & Accessories': 'Мода и аксессуары',
      'Home & Garden': 'Дом и сад',
      'Sports & Outdoors': 'Спорт и отдых',
      'Books & Media': 'Книги и медиа',
      'Baby & Kids': 'Детские товары',
      'Beauty & Personal Care': 'Красота и уход',
      'Automotive': 'Автомобили',
      'Furniture': 'Мебель',
      'Tools & Hardware': 'Инструменты',
      'Toys & Games': 'Игрушки и игры',
      'Health & Wellness': 'Здоровье',
      'Art & Crafts': 'Искусство и ремесла',
      'Music & Instruments': 'Музыка и инструменты',
      'Other': 'Другое',
    },
    'ja': {
      'Electronics': '電子機器',
      'Fashion & Accessories': 'ファッション・アクセサリー',
      'Home & Garden': 'ホーム・ガーデン',
      'Sports & Outdoors': 'スポーツ・アウトドア',
      'Books & Media': '本・メディア',
      'Baby & Kids': 'ベビー・キッズ',
      'Beauty & Personal Care': '美容・パーソナルケア',
      'Automotive': '自動車',
      'Furniture': '家具',
      'Tools & Hardware': '工具・ハードウェア',
      'Toys & Games': 'おもちゃ・ゲーム',
      'Health & Wellness': '健康・ウェルネス',
      'Art & Crafts': 'アート・クラフト',
      'Music & Instruments': '音楽・楽器',
      'Other': 'その他',
    },
  };
  
  // UI Text Translations
  static const Map<String, Map<String, String>> uiTranslations = {
    'en': {
      'app_name': projectName,
      'app_slogan': 'Share, Recycle, Live Sustainably',
      'login': 'Login',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'forgot_password': 'Forgot Password?',
      'login_with_google': 'Login with Google',
      'dont_have_account': 'Don\'t have an account?',
      'already_have_account': 'Already have an account?',
      'home': 'Home',
      'add_product': 'Add Product',
      'profile': 'Profile',
      'filter': 'Filter',
      'country_region': 'Country/Region',
      'city': 'City',
      'category': 'Category',
      'all_regions': 'All Regions',
      'all_cities': 'All Cities',
      'all_categories': 'All Categories',
      'apply': 'Apply',
      'cancel': 'Cancel',
      'settings': 'Settings',
      'language': 'Language',
      'change_language': 'Change Language',
      'select_language': 'Select Language',
      'edit_profile': 'Edit Profile',
      'notifications': 'Notifications',
      'help': 'Help',
      'feature_coming_soon': 'This feature is coming soon!',
      'logout': 'Logout',
      'logout_confirmation': 'Are you sure you want to logout?',
      'contact_info': 'Contact Info',
      'watch_ad_to_reveal': 'Watch ad to reveal contact info',
      'purchase_limit_reached': 'Daily purchase limit reached',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'required_field': 'This field is required',
      'invalid_email': 'Invalid email address',
      'password_too_short': 'Password must be at least 6 characters',
      'network_error': 'Check your internet connection',
      'unknown_error': 'An unknown error occurred',
    },
    'tr': {
      'app_name': projectName,
      'app_slogan': 'Paylaş, Geri Dönüştür, Sürdürülebilir Yaşa',
      'login': 'Giriş Yap',
      'register': 'Kayıt Ol',
      'email': 'E-posta',
      'password': 'Şifre',
      'forgot_password': 'Şifrenizi mi unuttunuz?',
      'login_with_google': 'Google ile Giriş',
      'dont_have_account': 'Hesabınız yok mu?',
      'already_have_account': 'Zaten hesabınız var mı?',
      'home': 'Ana Sayfa',
      'add_product': 'Ürün Ekle',
      'profile': 'Profil',
      'filter': 'Filtrele',
      'country_region': 'Ülke/Bölge',
      'city': 'Şehir',
      'category': 'Kategori',
      'all_regions': 'Tüm Bölgeler',
      'all_cities': 'Tüm Şehirler',
      'all_categories': 'Tüm Kategoriler',
      'apply': 'Uygula',
      'cancel': 'İptal',
      'settings': 'Ayarlar',
      'language': 'Dil',
      'change_language': 'Dil Değiştir',
      'select_language': 'Dil Seçin',
      'edit_profile': 'Profili Düzenle',
      'notifications': 'Bildirimler',
      'help': 'Yardım',
      'feature_coming_soon': 'Bu özellik yakında geliyor!',
      'logout': 'Çıkış Yap',
      'logout_confirmation': 'Çıkış yapmak istediğinizden emin misiniz?',
      'contact_info': 'İletişim Bilgisi',
      'watch_ad_to_reveal': 'İletişim bilgisini görmek için reklam izleyin',
      'purchase_limit_reached': 'Günlük satın alma limitine ulaştınız',
      'loading': 'Yükleniyor...',
      'error': 'Hata',
      'success': 'Başarılı',
      'required_field': 'Bu alan zorunludur',
      'invalid_email': 'Geçersiz e-posta adresi',
      'password_too_short': 'Şifre en az 6 karakter olmalıdır',
      'network_error': 'İnternet bağlantınızı kontrol edin',
      'unknown_error': 'Bilinmeyen bir hata oluştu',
    },
    'de': {
      'app_name': projectName,
      'app_slogan': 'Teilen, Recyceln, Nachhaltig Leben',
      'login': 'Anmelden',
      'register': 'Registrieren',
      'email': 'E-Mail',
      'password': 'Passwort',
      'forgot_password': 'Passwort vergessen?',
      'login_with_google': 'Mit Google anmelden',
      'dont_have_account': 'Noch kein Konto?',
      'already_have_account': 'Bereits ein Konto?',
      'home': 'Startseite',
      'add_product': 'Produkt hinzufügen',
      'profile': 'Profil',
      'filter': 'Filter',
      'country_region': 'Land/Region',
      'city': 'Stadt',
      'category': 'Kategorie',
      'all_regions': 'Alle Regionen',
      'all_cities': 'Alle Städte',
      'all_categories': 'Alle Kategorien',
      'apply': 'Anwenden',
      'cancel': 'Abbrechen',
      'settings': 'Einstellungen',
      'language': 'Sprache',
      'change_language': 'Sprache ändern',
      'select_language': 'Sprache auswählen',
      'edit_profile': 'Profil bearbeiten',
      'notifications': 'Benachrichtigungen',
      'help': 'Hilfe',
      'feature_coming_soon': 'Diese Funktion kommt bald!',
      'logout': 'Abmelden',
      'logout_confirmation': 'Sind Sie sicher, dass Sie sich abmelden möchten?',
      'contact_info': 'Kontaktinfo',
      'watch_ad_to_reveal': 'Werbung ansehen für Kontaktinfo',
      'purchase_limit_reached': 'Tägliches Kauflimit erreicht',
      'loading': 'Laden...',
      'error': 'Fehler',
      'success': 'Erfolgreich',
      'required_field': 'Dieses Feld ist erforderlich',
      'invalid_email': 'Ungültige E-Mail-Adresse',
      'password_too_short': 'Passwort muss mindestens 6 Zeichen haben',
      'network_error': 'Überprüfen Sie Ihre Internetverbindung',
      'unknown_error': 'Ein unbekannter Fehler ist aufgetreten',
    },
    'zh': {
      'app_name': projectName,
      'app_slogan': '分享、回收、可持续生活',
      'login': '登录',
      'register': '注册',
      'email': '邮箱',
      'password': '密码',
      'forgot_password': '忘记密码？',
      'login_with_google': '使用Google登录',
      'dont_have_account': '还没有账户？',
      'already_have_account': '已有账户？',
      'home': '首页',
      'add_product': '添加商品',
      'profile': '个人资料',
      'filter': '筛选',
      'country_region': '国家/地区',
      'city': '城市',
      'category': '类别',
      'all_regions': '所有地区',
      'all_cities': '所有城市',
      'all_categories': '所有类别',
      'apply': '应用',
      'cancel': '取消',
      'settings': '设置',
      'language': '语言',
      'change_language': '更改语言',
      'select_language': '选择语言',
      'edit_profile': '编辑个人资料',
      'notifications': '通知',
      'help': '帮助',
      'feature_coming_soon': '此功能即将推出！',
      'logout': '退出',
      'logout_confirmation': '您确定要退出吗？',
      'contact_info': '联系信息',
      'watch_ad_to_reveal': '观看广告以显示联系信息',
      'purchase_limit_reached': '已达到每日购买限制',
      'loading': '加载中...',
      'error': '错误',
      'success': '成功',
      'required_field': '此字段为必填项',
      'invalid_email': '无效的邮箱地址',
      'password_too_short': '密码至少需要6个字符',
      'network_error': '请检查您的网络连接',
      'unknown_error': '发生未知错误',
    },
    'ru': {
      'app_name': projectName,
      'app_slogan': 'Делись, Перерабатывай, Живи Устойчиво',
      'login': 'Войти',
      'register': 'Регистрация',
      'email': 'Электронная почта',
      'password': 'Пароль',
      'forgot_password': 'Забыли пароль?',
      'login_with_google': 'Войти через Google',
      'dont_have_account': 'Нет аккаунта?',
      'already_have_account': 'Уже есть аккаунт?',
      'home': 'Главная',
      'add_product': 'Добавить товар',
      'profile': 'Профиль',
      'filter': 'Фильтр',
      'country_region': 'Страна/Регион',
      'city': 'Город',
      'category': 'Категория',
      'all_regions': 'Все регионы',
      'all_cities': 'Все города',
      'all_categories': 'Все категории',
      'apply': 'Применить',
      'cancel': 'Отмена',
      'settings': 'Настройки',
      'language': 'Язык',
      'change_language': 'Изменить язык',
      'select_language': 'Выберите язык',
      'edit_profile': 'Редактировать профиль',
      'notifications': 'Уведомления',
      'help': 'Помощь',
      'feature_coming_soon': 'Эта функция скоро появится!',
      'logout': 'Выйти',
      'logout_confirmation': 'Вы уверены, что хотите выйти?',
      'contact_info': 'Контактная информация',
      'watch_ad_to_reveal': 'Посмотрите рекламу для просмотра контактов',
      'purchase_limit_reached': 'Достигнут дневной лимит покупок',
      'loading': 'Загрузка...',
      'error': 'Ошибка',
      'success': 'Успешно',
      'required_field': 'Это поле обязательно',
      'invalid_email': 'Неверный адрес электронной почты',
      'password_too_short': 'Пароль должен содержать не менее 6 символов',
      'network_error': 'Проверьте подключение к интернету',
      'unknown_error': 'Произошла неизвестная ошибка',
    },
    'ja': {
      'app_name': projectName,
      'app_slogan': 'シェア、リサイクル、持続可能な生活',
      'login': 'ログイン',
      'register': '登録',
      'email': 'メール',
      'password': 'パスワード',
      'forgot_password': 'パスワードを忘れましたか？',
      'login_with_google': 'Googleでログイン',
      'dont_have_account': 'アカウントをお持ちでない方',
      'already_have_account': 'すでにアカウントをお持ちの方',
      'home': 'ホーム',
      'add_product': '商品を追加',
      'profile': 'プロフィール',
      'filter': 'フィルター',
      'country_region': '国/地域',
      'city': '都市',
      'category': 'カテゴリー',
      'all_regions': 'すべての地域',
      'all_cities': 'すべての都市',
      'all_categories': 'すべてのカテゴリー',
      'apply': '適用',
      'cancel': 'キャンセル',
      'settings': '設定',
      'language': '言語',
      'change_language': '言語を変更',
      'select_language': '言語を選択',
      'edit_profile': 'プロフィールを編集',
      'notifications': '通知',
      'help': 'ヘルプ',
      'feature_coming_soon': 'この機能は近日公開予定です！',
      'logout': 'ログアウト',
      'logout_confirmation': 'ログアウトしてもよろしいですか？',
      'contact_info': '連絡先情報',
      'watch_ad_to_reveal': '連絡先を表示するには広告を視聴してください',
      'purchase_limit_reached': '1日の購入制限に達しました',
      'loading': '読み込み中...',
      'error': 'エラー',
      'success': '成功',
      'required_field': 'この項目は必須です',
      'invalid_email': '無効なメールアドレス',
      'password_too_short': 'パスワードは6文字以上である必要があります',
      'network_error': 'インターネット接続を確認してください',
      'unknown_error': '不明なエラーが発生しました',
    },
  };
  static const int maxImageCount = 5;
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 500;
  static const Duration adWatchTimeout = Duration(seconds: 30);
  
  // Error Messages
  static const String networkError = 'İnternet bağlantınızı kontrol edin';
  static const String unknownError = 'Bilinmeyen bir hata oluştu';
  static const String purchaseLimitReached = 'Satın alma limitiniz dolmuş. Daha fazla ürün alamazsınız.';
  static const String contactInfoHidden = 'İletişim bilgisini görmek için reklam izlemelisiniz';
}
