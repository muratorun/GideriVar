import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class LocationModel {
  final String name;
  final String code;
  final String? flag;

  LocationModel({
    required this.name,
    required this.code,
    this.flag,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      name: json['name']?['common'] ?? json['name'] ?? '',
      code: json['cca2'] ?? json['code'] ?? '',
      flag: json['flag'] ?? json['emoji'],
    );
  }
}

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  List<LocationModel> _countries = [];
  List<LocationModel> _cities = [];
  bool _countriesLoaded = false;

  // REST Countries API'den ülkeleri çek
  Future<List<LocationModel>> getCountries() async {
    if (_countriesLoaded) return _countries;

    try {
      final response = await http.get(
        Uri.parse('https://restcountries.com/v3.1/all?fields=name,cca2,flag'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _countries = data
            .map((country) => LocationModel.fromJson(country))
            .where((country) => country.name.isNotEmpty)
            .toList();
        
        // Alfabetik sırala
        _countries.sort((a, b) => a.name.compareTo(b.name));
        _countriesLoaded = true;
        return _countries;
      } else {
        throw Exception('Failed to load countries: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading countries: $e');
      // Fallback olarak temel ülkeler döndür
      return _getFallbackCountries();
    }
  }

  // GeoDB Cities API'den şehirleri çek (ücretsiz plan: 10 req/sec, 1000 req/day)
  Future<List<LocationModel>> getCitiesByCountry(String countryCode) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://wft-geo-db.p.rapidapi.com/v1/geo/countries/$countryCode/places?types=CITY&limit=100'
        ),
        headers: {
          'X-RapidAPI-Key': 'YOUR_RAPIDAPI_KEY', // Bu key'i kullanıcıdan alınacak
          'X-RapidAPI-Host': 'wft-geo-db.p.rapidapi.com',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> cities = data['data'] ?? [];
        
        return cities
            .map((city) => LocationModel(
                  name: city['name'] ?? '',
                  code: city['id']?.toString() ?? '',
                ))
            .where((city) => city.name.isNotEmpty)
            .toList();
      } else {
        throw Exception('Failed to load cities: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading cities for $countryCode: $e');
      // Fallback için boş liste döndür
      return [];
    }
  }

  // Alternatif: OpenStreetMap Nominatim API (ücretsiz ama rate limited)
  Future<List<LocationModel>> searchLocations(String query) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=20'
        ),
        headers: {
          'User-Agent': '${AppConstants.projectName}App/1.0', // Nominatim requires user-agent
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((location) => LocationModel(
                  name: location['display_name']?.split(',')[0] ?? '',
                  code: location['place_id']?.toString() ?? '',
                ))
            .where((location) => location.name.isNotEmpty)
            .toList();
      } else {
        throw Exception('Failed to search locations: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching locations: $e');
      return [];
    }
  }

  // Kullanıcının GPS konumuna göre en yakın şehri bul
  Future<LocationModel?> getCurrentLocation() async {
    try {
      // Bu kısım location package ile genişletilebilir
      // Şimdilik basit IP tabanlı konum döndürelim
      final response = await http.get(
        Uri.parse('https://ipapi.co/json/'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return LocationModel(
          name: data['city'] ?? data['region'] ?? '',
          code: data['country_code'] ?? '',
          flag: _getCountryFlag(data['country_code'] ?? ''),
        );
      }
    } catch (e) {
      print('Error getting current location: $e');
    }
    return null;
  }

  // Cache'i temizle
  void clearCache() {
    _countries.clear();
    _cities.clear();
    _countriesLoaded = false;
  }

  // Fallback ülkeler (API çalışmazsa)
  List<LocationModel> _getFallbackCountries() {
    return [
      LocationModel(name: 'Türkiye', code: 'TR', flag: '🇹🇷'),
      LocationModel(name: 'United States', code: 'US', flag: '🇺🇸'),
      LocationModel(name: 'United Kingdom', code: 'GB', flag: '🇬🇧'),
      LocationModel(name: 'Germany', code: 'DE', flag: '🇩🇪'),
      LocationModel(name: 'France', code: 'FR', flag: '🇫🇷'),
      LocationModel(name: 'Italy', code: 'IT', flag: '🇮🇹'),
      LocationModel(name: 'Spain', code: 'ES', flag: '🇪🇸'),
      LocationModel(name: 'Canada', code: 'CA', flag: '🇨🇦'),
      LocationModel(name: 'Australia', code: 'AU', flag: '🇦🇺'),
      LocationModel(name: 'Japan', code: 'JP', flag: '🇯🇵'),
      LocationModel(name: 'South Korea', code: 'KR', flag: '🇰🇷'),
      LocationModel(name: 'Brazil', code: 'BR', flag: '🇧🇷'),
      LocationModel(name: 'India', code: 'IN', flag: '🇮🇳'),
      LocationModel(name: 'China', code: 'CN', flag: '🇨🇳'),
      LocationModel(name: 'Russia', code: 'RU', flag: '🇷🇺'),
    ];
  }

  // Türkiye şehirleri fallback
  List<LocationModel> getTurkishCities() {
    const cities = [
      'İstanbul', 'Ankara', 'İzmir', 'Bursa', 'Antalya', 'Adana', 'Konya',
      'Gaziantep', 'Mersin', 'Diyarbakır', 'Kayseri', 'Eskişehir', 'Urfa',
      'Malatya', 'Erzurum', 'Van', 'Batman', 'Elazığ', 'Iğdır', 'Trabzon',
      'Sakarya', 'Denizli', 'Muğla', 'Tekirdağ', 'Balıkesir', 'Kocaeli',
      'Kahramanmaraş', 'Samsun', 'Mardin', 'Aydın', 'Hatay', 'Manisa',
    ];
    
    return cities
        .map((city) => LocationModel(name: city, code: city.toLowerCase()))
        .toList();
  }

  String _getCountryFlag(String countryCode) {
    final flags = {
      'TR': '🇹🇷', 'US': '🇺🇸', 'GB': '🇬🇧', 'DE': '🇩🇪', 'FR': '🇫🇷',
      'IT': '🇮🇹', 'ES': '🇪🇸', 'CA': '🇨🇦', 'AU': '🇦🇺', 'JP': '🇯🇵',
      'KR': '🇰🇷', 'BR': '🇧🇷', 'IN': '🇮🇳', 'CN': '🇨🇳', 'RU': '🇷🇺',
    };
    return flags[countryCode] ?? '🌍';
  }
}
