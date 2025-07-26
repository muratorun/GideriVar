class AppConstants {
  // Parametrik değerler - kolayca değiştirilebilir
  static const int defaultPurchaseLimit = 1;
  static const int premiumPurchaseLimit = 5;
  
  // Firebase Collection Names
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String purchasesCollection = 'purchases';
  
  // Regions
  static const List<String> turkishCities = [
    'Adana', 'Adıyaman', 'Afyonkarahisar', 'Ağrı', 'Amasya', 'Ankara', 'Antalya',
    'Artvin', 'Aydın', 'Balıkesir', 'Bilecik', 'Bingöl', 'Bitlis', 'Bolu',
    'Burdur', 'Bursa', 'Çanakkale', 'Çankırı', 'Çorum', 'Denizli', 'Diyarbakır',
    'Edirne', 'Elazığ', 'Erzincan', 'Erzurum', 'Eskişehir', 'Gaziantep', 'Giresun',
    'Gümüşhane', 'Hakkâri', 'Hatay', 'Isparta', 'Mersin', 'İstanbul', 'İzmir',
    'Kars', 'Kastamonu', 'Kayseri', 'Kırklareli', 'Kırşehir', 'Kocaeli', 'Konya',
    'Kütahya', 'Malatya', 'Manisa', 'Kahramanmaraş', 'Mardin', 'Muğla', 'Muş',
    'Nevşehir', 'Niğde', 'Ordu', 'Rize', 'Sakarya', 'Samsun', 'Siirt', 'Sinop',
    'Sivas', 'Tekirdağ', 'Tokat', 'Trabzon', 'Tunceli', 'Şanlıurfa', 'Uşak',
    'Van', 'Yozgat', 'Zonguldak', 'Aksaray', 'Bayburt', 'Karaman', 'Kırıkkale',
    'Batman', 'Şırnak', 'Bartın', 'Ardahan', 'Iğdır', 'Yalova', 'Karabük', 'Kilis',
    'Osmaniye', 'Düzce'
  ];
  
  // Categories
  static const List<String> categories = [
    'Elektronik',
    'Ev & Yaşam',
    'Giyim & Aksesuar',
    'Spor & Outdoor',
    'Kitap & Hobi',
    'Bebek & Çocuk',
    'Kozmetik & Kişisel Bakım',
    'Ev Aletleri',
    'Mobilya',
    'Diğer'
  ];
  
  // App Settings
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
