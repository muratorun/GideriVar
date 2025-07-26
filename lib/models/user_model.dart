class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final int purchaseLimit; // Kullanıcının satın alabileceği maksimum ürün sayısı
  final int currentPurchases; // Kullanıcının şu anki satın alma sayısı
  final String? region; // Kullanıcının seçtiği bölge

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    this.purchaseLimit = 1, // Varsayılan olarak 1 ürün
    this.currentPurchases = 0,
    this.region,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'purchaseLimit': purchaseLimit,
      'currentPurchases': currentPurchases,
      'region': region,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'],
      photoUrl: map['photoUrl'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      purchaseLimit: map['purchaseLimit'] ?? 1,
      currentPurchases: map['currentPurchases'] ?? 0,
      region: map['region'],
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    int? purchaseLimit,
    int? currentPurchases,
    String? region,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      purchaseLimit: purchaseLimit ?? this.purchaseLimit,
      currentPurchases: currentPurchases ?? this.currentPurchases,
      region: region ?? this.region,
    );
  }

  bool canPurchase() {
    return currentPurchases < purchaseLimit;
  }
}
