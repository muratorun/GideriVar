import 'package:hive/hive.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 0)
class SettingsModel extends HiveObject {
  @HiveField(0)
  String language;

  @HiveField(1)
  bool useOnlineLocationService;

  @HiveField(2)
  bool isDarkMode;

  @HiveField(3)
  String? lastSelectedCountry;

  @HiveField(4)
  String? lastSelectedCity;

  @HiveField(5)
  bool notificationsEnabled;

  @HiveField(6)
  bool soundEnabled;

  SettingsModel({
    required this.language,
    this.useOnlineLocationService = true,
    this.isDarkMode = false,
    this.lastSelectedCountry,
    this.lastSelectedCity,
    this.notificationsEnabled = true,
    this.soundEnabled = true,
  });

  SettingsModel copyWith({
    String? language,
    bool? useOnlineLocationService,
    bool? isDarkMode,
    String? lastSelectedCountry,
    String? lastSelectedCity,
    bool? notificationsEnabled,
    bool? soundEnabled,
  }) {
    return SettingsModel(
      language: language ?? this.language,
      useOnlineLocationService: useOnlineLocationService ?? this.useOnlineLocationService,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      lastSelectedCountry: lastSelectedCountry ?? this.lastSelectedCountry,
      lastSelectedCity: lastSelectedCity ?? this.lastSelectedCity,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'language': language,
      'useOnlineLocationService': useOnlineLocationService,
      'isDarkMode': isDarkMode,
      'lastSelectedCountry': lastSelectedCountry,
      'lastSelectedCity': lastSelectedCity,
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
    };
  }

  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      language: map['language'] ?? 'en',
      useOnlineLocationService: map['useOnlineLocationService'] ?? true,
      isDarkMode: map['isDarkMode'] ?? false,
      lastSelectedCountry: map['lastSelectedCountry'],
      lastSelectedCity: map['lastSelectedCity'],
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      soundEnabled: map['soundEnabled'] ?? true,
    );
  }
}
