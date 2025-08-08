class LocationModel {
  final String name;
  final String code;
  final String? flag;

  LocationModel({
    required this.name,
    required this.code,
    this.flag,
  });

  @override
  String toString() {
    return 'LocationModel(name: $name, code: $code, flag: $flag)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationModel &&
        other.name == name &&
        other.code == code &&
        other.flag == flag;
  }

  @override
  int get hashCode => name.hashCode ^ code.hashCode ^ flag.hashCode;

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'flag': flag,
    };
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      flag: json['flag'],
    );
  }
}
