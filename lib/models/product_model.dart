import 'contact_method.dart';

class ProductModel {
  final String id;
  final String title;
  final String description;
  final List<String> imageUrls;
  final String sellerId;
  final String sellerName;
  final List<ContactMethod> contactMethods; // Çoklu iletişim kanalları
  final DateTime createdAt;
  final bool isActive;
  final String region;
  final String? category;
  final bool isPremium; // Premium ilanlar üstte gösterilir

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrls,
    required this.sellerId,
    required this.sellerName,
    required this.contactMethods,
    required this.createdAt,
    this.isActive = true,
    required this.region,
    this.category,
    this.isPremium = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrls': imageUrls,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'contactMethods': contactMethods.map((method) => method.toMap()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isActive': isActive,
      'region': region,
      'category': category,
      'isPremium': isPremium,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      contactMethods: (map['contactMethods'] as List<dynamic>?)
          ?.map((methodMap) => ContactMethod.fromMap(methodMap as Map<String, dynamic>))
          .toList() ?? [],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      isActive: map['isActive'] ?? true,
      region: map['region'] ?? '',
      category: map['category'],
      isPremium: map['isPremium'] ?? false,
    );
  }

  ProductModel copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? imageUrls,
    String? sellerId,
    String? sellerName,
    List<ContactMethod>? contactMethods,
    DateTime? createdAt,
    bool? isActive,
    String? region,
    String? category,
    bool? isPremium,
  }) {
    return ProductModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      contactMethods: contactMethods ?? this.contactMethods,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      region: region ?? this.region,
      category: category ?? this.category,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}
