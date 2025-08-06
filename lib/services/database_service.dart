import '../models/product_model.dart';
import '../models/user_model.dart';
import '../models/contact_method.dart';
import '../utils/constants.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // Simüle edilmiş veriler - Firebase entegrasyonunda değiştirilecek
  final List<ProductModel> _products = [];
  final List<UserModel> _users = [];

  // Kullanıcı oluştur/güncelle
  Future<bool> createOrUpdateUser(UserModel user) async {
    try {
      // Firestore entegrasyonu eklenecek
      final index = _users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _users[index] = user;
      } else {
        _users.add(user);
      }
      return true;
    } catch (e) {
      print('User create/update error: $e');
      return false;
    }
  }

  // Kullanıcı getir
  Future<UserModel?> getUser(String userId) async {
    try {
      // Firestore entegrasyonu eklenecek
      await Future.delayed(const Duration(milliseconds: 500)); // Simülasyon
      return _users.firstWhere(
        (user) => user.id == userId,
        orElse: () => UserModel(
          id: userId,
          email: 'test@example.com',
          createdAt: DateTime.now(),
        ),
      );
    } catch (e) {
      print('Get user error: $e');
      return null;
    }
  }

  // Ürün oluştur
  Future<bool> createProduct(ProductModel product) async {
    try {
      // Firestore entegrasyonu eklenecek
      _products.add(product);
      return true;
    } catch (e) {
      print('Product create error: $e');
      return false;
    }
  }

  // Belirli bölgedeki ürünleri getir
  Future<List<ProductModel>> getProductsByRegion(String region) async {
    try {
      // Firestore query entegrasyonu eklenecek
      await Future.delayed(const Duration(milliseconds: 800)); // Simülasyon
      
      // Demo ürünler oluştur
      if (_products.isEmpty) {
        _createDemoProducts();
      }
      
      return _products
          .where((product) => product.region == region && product.isActive)
          .toList()
        ..sort((a, b) {
          // Premium ürünleri üstte göster
          if (a.isPremium && !b.isPremium) return -1;
          if (!a.isPremium && b.isPremium) return 1;
          return b.createdAt.compareTo(a.createdAt); // Yeniden eskiye
        });
    } catch (e) {
      print('Get products error: $e');
      return [];
    }
  }

  // Tüm ürünleri getir
  Future<List<ProductModel>> getAllProducts() async {
    try {
      // Firestore entegrasyonu eklenecek
      await Future.delayed(const Duration(milliseconds: 800)); // Simülasyon
      
      if (_products.isEmpty) {
        _createDemoProducts();
      }
      
      return _products
          .where((product) => product.isActive)
          .toList()
        ..sort((a, b) {
          if (a.isPremium && !b.isPremium) return -1;
          if (!a.isPremium && b.isPremium) return 1;
          return b.createdAt.compareTo(a.createdAt);
        });
    } catch (e) {
      print('Get all products error: $e');
      return [];
    }
  }

  // Kullanıcının ürünlerini getir
  Future<List<ProductModel>> getUserProducts(String userId) async {
    try {
      // Firestore query entegrasyonu eklenecek
      await Future.delayed(const Duration(milliseconds: 500)); // Simülasyon
      return _products
          .where((product) => product.sellerId == userId)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      print('Get user products error: $e');
      return [];
    }
  }

  // Ürün sil
  Future<bool> deleteProduct(String productId) async {
    try {
      // Firestore entegrasyonu eklenecek
      _products.removeWhere((product) => product.id == productId);
      return true;
    } catch (e) {
      print('Delete product error: $e');
      return false;
    }
  }

  // Kullanıcının satın alma sayısını artır
  Future<bool> incrementUserPurchaseCount(String userId) async {
    try {
      // Firestore entegrasyonu eklenecek
      final userIndex = _users.indexWhere((u) => u.id == userId);
      if (userIndex != -1) {
        _users[userIndex] = _users[userIndex].copyWith(
          currentPurchases: _users[userIndex].currentPurchases + 1,
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Increment purchase count error: $e');
      return false;
    }
  }

  // Kullanıcının satın alma sayısını artır (alias metod)
  Future<bool> incrementUserPurchases(String userId) async {
    return incrementUserPurchaseCount(userId);
  }

  // Demo ürünler oluştur
  void _createDemoProducts() {
    final demoProducts = [
      ProductModel(
        id: '1',
        title: 'iPhone 12 Pro',
        description: 'Temiz kullanılmış iPhone 12 Pro. Hiçbir problemi yok.',
        imageUrls: ['assets/icon/icon.png'], // Yerel asset kullan
        sellerId: 'seller1',
        sellerName: 'Ahmet Yılmaz',
        contactMethods: [
          ContactMethod(
            type: ContactMethodType.whatsapp,
            value: '+90 555 123 4567',
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        region: 'İstanbul',
        category: 'Elektronik',
        isPremium: true,
      ),
      ProductModel(
        id: '2',
        title: 'MacBook Air M1',
        description: 'Az kullanılmış MacBook Air M1. Kutusu ve şarj cihazı mevcut.',
        imageUrls: ['assets/icon/icon.png'], // Yerel asset kullan
        sellerId: 'seller2',
        sellerName: 'Zeynep Kaya',
        contactMethods: [
          ContactMethod(
            type: ContactMethodType.phone,
            value: '+90 533 987 6543',
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        region: 'Ankara',
        category: 'Elektronik',
      ),
      ProductModel(
        id: '3',
        title: 'Gömlek Takımı',
        description: 'Hiç giyilmemiş erkek gömlek takımı. Bedeni L.',
        imageUrls: ['assets/icon/icon.png'], // Yerel asset kullan
        sellerId: 'seller3',
        sellerName: 'Mehmet Demir',
        contactMethods: [
          ContactMethod(
            type: ContactMethodType.instagram,
            value: '@mehmet.demir',
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        region: 'İzmir',
        category: 'Giyim & Aksesuar',
      ),
    ];
    
    _products.addAll(demoProducts);
  }
}
