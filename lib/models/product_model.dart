enum ContactType {
  phone,
  whatsapp,
  email,
  instagram,
}

extension ContactTypeExtension on ContactType {
  String get displayName {
    switch (this) {
      case ContactType.phone:
        return 'Telefon';
      case ContactType.whatsapp:
        return 'WhatsApp';
      case ContactType.email:
        return 'E-posta';
      case ContactType.instagram:
        return 'Instagram';
    }
  }

  String get icon {
    switch (this) {
      case ContactType.phone:
        return '📞';
      case ContactType.whatsapp:
        return '💬';
      case ContactType.email:
        return '📧';
      case ContactType.instagram:
        return '📷';
    }
  }
}

class ProductModel {
  final String id;
  final String title;
  final String description;
  final List<String> imageUrls;
  final String sellerId;
  final String sellerName;
  final ContactType contactType;
  final String contactInfo;
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
    required this.contactType,
    required this.contactInfo,
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
      'contactType': contactType.index,
      'contactInfo': contactInfo,
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
      contactType: ContactType.values[map['contactType'] ?? 0],
      contactInfo: map['contactInfo'] ?? '',
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
    ContactType? contactType,
    String? contactInfo,
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
      contactType: contactType ?? this.contactType,
      contactInfo: contactInfo ?? this.contactInfo,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      region: region ?? this.region,
      category: category ?? this.category,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}
