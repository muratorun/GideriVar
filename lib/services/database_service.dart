import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // Firebase Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection references
  CollectionReference get _usersCollection => 
      _firestore.collection(AppConstants.usersCollection);
  CollectionReference get _productsCollection => 
      _firestore.collection(AppConstants.productsCollection);

  // Cache için yerel veriler (offline destek)
  final List<ProductModel> _products = [];
  final List<UserModel> _users = [];

  // Kullanıcı oluştur/güncelle
  Future<bool> createOrUpdateUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.id).set(user.toMap());
      
      // Cache güncelle
      final index = _users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _users[index] = user;
      } else {
        _users.add(user);
      }
      
      debugPrint('User created/updated: ${user.id}');
      return true;
    } catch (e) {
      debugPrint('User create/update error: $e');
      return false;
    }
  }

  // Kullanıcı getir
  Future<UserModel?> getUser(String userId) async {
    try {
      // Önce cache'den kontrol et
      final cachedUser = _users.where((u) => u.id == userId).firstOrNull;
      if (cachedUser != null) {
        return cachedUser;
      }
      
      // Firestore'dan getir
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        final user = UserModel.fromMap(doc.data() as Map<String, dynamic>);
        _users.add(user); // Cache'e ekle
        return user;
      }
      
      // Kullanıcı yoksa varsayılan oluştur
      final newUser = UserModel(
        id: userId,
        email: 'user@giderivar.com',
        displayName: 'User',
        createdAt: DateTime.now(),
        purchaseLimit: AppConstants.defaultPurchaseLimit,
        currentPurchases: 0,
        region: 'Türkiye',
      );
      
      await createOrUpdateUser(newUser);
      return newUser;
    } catch (e) {
      debugPrint('Get user error: $e');
      return null;
    }
  }

  // Ürün oluştur
  Future<bool> createProduct(ProductModel product) async {
    try {
      await _productsCollection.doc(product.id).set(product.toMap());
      
      // Cache'e ekle
      _products.add(product);
      
      debugPrint('Product created: ${product.title}');
      return true;
    } catch (e) {
      debugPrint('Product create error: $e');
      return false;
    }
  }

  // Belirli bölgedeki ürünleri getir
  Future<List<ProductModel>> getProductsByRegion(String region) async {
    try {
      Query query = _productsCollection
          .where('isActive', isEqualTo: true)
          .orderBy('isPremium', descending: true)
          .orderBy('createdAt', descending: true);
      
      if (region != 'Tümü' && region != 'All') {
        query = query.where('region', isEqualTo: region);
      }
      
      final querySnapshot = await query.get();
      
      final products = querySnapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      
      // Cache güncelle
      _products.clear();
      _products.addAll(products);
      
      debugPrint('Loaded ${products.length} products for region: $region');
      return products;
    } catch (e) {
      debugPrint('Get products by region error: $e');
      return []; // Hata durumunda boş liste dön
    }
  }

  // Tüm ürünleri getir
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final querySnapshot = await _productsCollection
          .where('isActive', isEqualTo: true)
          .orderBy('isPremium', descending: true)
          .orderBy('createdAt', descending: true)
          .get();
      
      final products = querySnapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      
      // Cache güncelle
      _products.clear();
      _products.addAll(products);
      
      debugPrint('Loaded ${products.length} products total');
      return products;
    } catch (e) {
      debugPrint('Get all products error: $e');
      return []; // Hata durumunda boş liste dön
    }
  }

  // Kullanıcının ürünlerini getir
  Future<List<ProductModel>> getUserProducts(String userId) async {
    try {
      final querySnapshot = await _productsCollection
          .where('sellerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      final products = querySnapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      
      debugPrint('Loaded ${products.length} products for user: $userId');
      return products;
    } catch (e) {
      debugPrint('Get user products error: $e');
      
      // Cache'den kullanıcının ürünlerini dön
      return _products
          .where((product) => product.sellerId == userId)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
  }

  // Ürün sil
  Future<bool> deleteProduct(String productId) async {
    try {
      // Firestore'dan sil
      await _productsCollection.doc(productId).delete();
      
      // Cache'den sil
      _products.removeWhere((product) => product.id == productId);
      
      debugPrint('Product deleted: $productId');
      return true;
    } catch (e) {
      debugPrint('Delete product error: $e');
      return false;
    }
  }

  // Kullanıcının satın alma sayısını artır
  Future<bool> incrementUserPurchaseCount(String userId) async {
    try {
      final userDoc = _usersCollection.doc(userId);
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        
        if (snapshot.exists) {
          final currentCount = (snapshot.data() as Map<String, dynamic>)['currentPurchases'] ?? 0;
          transaction.update(userDoc, {'currentPurchases': currentCount + 1});
        } else {
          // Kullanıcı yoksa oluştur
          transaction.set(userDoc, {
            'id': userId,
            'email': 'user@giderivar.com',
            'displayName': 'User',
            'createdAt': FieldValue.serverTimestamp(),
            'purchaseLimit': AppConstants.defaultPurchaseLimit,
            'currentPurchases': 1,
            'region': 'Türkiye',
          });
        }
      });
      
      // Cache güncelle
      final userIndex = _users.indexWhere((u) => u.id == userId);
      if (userIndex != -1) {
        _users[userIndex] = _users[userIndex].copyWith(
          currentPurchases: _users[userIndex].currentPurchases + 1,
        );
      }
      
      debugPrint('User purchase count incremented: $userId');
      return true;
    } catch (e) {
      debugPrint('Increment purchase count error: $e');
      return false;
    }
  }

  // Kullanıcının satın alma sayısını artır (alias metod)
  Future<bool> incrementUserPurchases(String userId) async {
    return incrementUserPurchaseCount(userId);
  }
}
