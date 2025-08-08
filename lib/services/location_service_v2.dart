import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/location_model.dart';
import '../utils/constants.dart';

class LocationServiceV2 {
  static final LocationServiceV2 _instance = LocationServiceV2._internal();
  factory LocationServiceV2() => _instance;
  LocationServiceV2._internal();

  List<LocationModel> _countries = [];
  Map<String, List<LocationModel>> _citiesCache = {};
  bool _countriesLoaded = false;

  // Ülkeleri getir - REST Countries API (ücretsiz ve güvenilir)
  Future<List<LocationModel>> getCountries() async {
    if (_countriesLoaded && _countries.isNotEmpty) {
      return _countries;
    }

    try {
      debugPrint('Loading countries from REST Countries API...');
      final response = await http.get(
        Uri.parse('https://restcountries.com/v3.1/all?fields=name,cca2,flag'),
        headers: {
          'User-Agent': 'GideriVar/1.0',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        _countries = data
            .map((country) {
              final name = country['name']['common'] ?? '';
              final code = country['cca2'] ?? '';
              final flag = country['flag'] ?? '';
              
              return LocationModel(
                name: name,
                code: code,
                flag: flag,
              );
            })
            .where((country) => country.name.isNotEmpty && country.code.isNotEmpty)
            .toList();

        // Alfabetik sıralama
        _countries.sort((a, b) => a.name.compareTo(b.name));
        
        // Türkiye'yi en üste taşı
        final turkeyIndex = _countries.indexWhere((c) => c.code == 'TR');
        if (turkeyIndex != -1) {
          final turkey = _countries.removeAt(turkeyIndex);
          _countries.insert(0, turkey);
        }

        _countriesLoaded = true;
        debugPrint('Loaded ${_countries.length} countries successfully');
        return _countries;
      } else {
        throw Exception('Failed to load countries: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error loading countries: $e');
      return _getFallbackCountries();
    }
  }

  // Şehirleri getir - Gelişmiş fallback sistemi ile
  Future<List<LocationModel>> getCitiesByCountry(String countryCode) async {
    final cacheKey = countryCode.toUpperCase();
    
    // Cache'den kontrol et
    if (_citiesCache.containsKey(cacheKey)) {
      debugPrint('Returning cached cities for $countryCode');
      return _citiesCache[cacheKey]!;
    }

    try {
      List<LocationModel> cities = [];
      
      // Türkiye için özel liste
      if (countryCode.toUpperCase() == 'TR') {
        cities = getTurkishCities();
      } else {
        // Diğer ülkeler için online API dene
        cities = await _fetchCitiesFromAPI(countryCode);
        
        // API başarısızsa fallback kullan
        if (cities.isEmpty) {
          cities = _getFallbackCitiesForCountry(countryCode);
        }
      }

      // Cache'e kaydet
      _citiesCache[cacheKey] = cities;
      debugPrint('Loaded ${cities.length} cities for $countryCode');
      return cities;
      
    } catch (e) {
      debugPrint('Error loading cities for $countryCode: $e');
      return _getFallbackCitiesForCountry(countryCode);
    }
  }

  // Online API'den şehir çek
  Future<List<LocationModel>> _fetchCitiesFromAPI(String countryCode) async {
    try {
      // GeoDB Cities API
      debugPrint('Fetching cities from GeoDB API for $countryCode...');
      final response = await http.get(
        Uri.parse(
          'https://wft-geo-db.p.rapidapi.com/v1/geo/countries/$countryCode/places?types=CITY&limit=100'
        ),
        headers: {
          'X-RapidAPI-Key': AppConstants.rapidApiKey,
          'X-RapidAPI-Host': 'wft-geo-db.p.rapidapi.com',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> citiesData = data['data'] ?? [];
        
        return citiesData
            .map((city) => LocationModel(
                  name: city['name'] ?? '',
                  code: city['id']?.toString() ?? '',
                ))
            .where((city) => city.name.isNotEmpty)
            .toList();
      }
    } catch (e) {
      debugPrint('GeoDB API error: $e');
    }

    // Alternatif API: OpenStreetMap Nominatim
    try {
      debugPrint('Trying Nominatim API for $countryCode...');
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search?country=$countryCode&featuretype=city&format=json&limit=50'
        ),
        headers: {
          'User-Agent': 'GideriVar/1.0',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        return data
            .map((location) => LocationModel(
                  name: location['display_name']?.split(',')[0] ?? '',
                  code: location['place_id']?.toString() ?? '',
                ))
            .where((location) => location.name.isNotEmpty)
            .take(30) // Limit to 30 cities
            .toList();
      }
    } catch (e) {
      debugPrint('Nominatim API error: $e');
    }

    return [];
  }

  // Ülke bazında fallback şehirler
  List<LocationModel> _getFallbackCitiesForCountry(String countryCode) {
    final Map<String, List<String>> fallbackCities = {
      'US': ['New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix', 'Philadelphia', 'San Antonio', 'San Diego', 'Dallas', 'San Jose'],
      'GB': ['London', 'Birmingham', 'Liverpool', 'Sheffield', 'Bristol', 'Glasgow', 'Leicester', 'Edinburgh', 'Leeds', 'Cardiff'],
      'DE': ['Berlin', 'Hamburg', 'Munich', 'Cologne', 'Frankfurt', 'Stuttgart', 'Düsseldorf', 'Leipzig', 'Dortmund', 'Essen'],
      'FR': ['Paris', 'Marseille', 'Lyon', 'Toulouse', 'Nice', 'Nantes', 'Montpellier', 'Strasbourg', 'Bordeaux', 'Lille'],
      'IT': ['Rome', 'Milan', 'Naples', 'Turin', 'Palermo', 'Genoa', 'Bologna', 'Florence', 'Bari', 'Catania'],
      'ES': ['Madrid', 'Barcelona', 'Valencia', 'Seville', 'Zaragoza', 'Málaga', 'Murcia', 'Palma', 'Las Palmas', 'Bilbao'],
      'CA': ['Toronto', 'Montreal', 'Calgary', 'Ottawa', 'Edmonton', 'Mississauga', 'Winnipeg', 'Vancouver', 'Brampton', 'Hamilton'],
      'AU': ['Sydney', 'Melbourne', 'Brisbane', 'Perth', 'Adelaide', 'Gold Coast', 'Newcastle', 'Canberra', 'Sunshine Coast', 'Wollongong'],
      'JP': ['Tokyo', 'Yokohama', 'Osaka', 'Nagoya', 'Sapporo', 'Fukuoka', 'Kobe', 'Kawasaki', 'Kyoto', 'Saitama'],
      'KR': ['Seoul', 'Busan', 'Incheon', 'Daegu', 'Daejeon', 'Gwangju', 'Suwon', 'Ulsan', 'Changwon', 'Goyang'],
    };

    final cities = fallbackCities[countryCode.toUpperCase()] ?? ['Main City', 'City Center'];
    
    return cities
        .map((city) => LocationModel(name: city, code: city.toLowerCase()))
        .toList();
  }

  // Türkiye şehirleri (güncellenmiş ve genişletilmiş)
  List<LocationModel> getTurkishCities() {
    const cities = [
      'İstanbul', 'Ankara', 'İzmir', 'Bursa', 'Antalya', 'Adana', 'Konya',
      'Gaziantep', 'Mersin', 'Diyarbakır', 'Kayseri', 'Eskişehir', 'Urfa',
      'Malatya', 'Erzurum', 'Van', 'Batman', 'Elazığ', 'Iğdır', 'Trabzon',
      'Sakarya', 'Denizli', 'Muğla', 'Tekirdağ', 'Balıkesir', 'Kocaeli',
      'Kahramanmaraş', 'Samsun', 'Mardin', 'Aydın', 'Hatay', 'Manisa',
      'Afyonkarahisar', 'Zonguldak', 'Tokat', 'Çorum', 'Ordu', 'Giresun',
      'Ağrı', 'Kırklareli', 'Isparta', 'Burdur', 'Karabük', 'Yalova',
      'Rize', 'Artvin', 'Çanakkale', 'Sinop', 'Amasya', 'Nevşehir',
      'Kırşehir', 'Niğde', 'Aksaray', 'Karaman', 'Kırıkkale', 'Yozgat',
      'Sivas', 'Erzincan', 'Bingöl', 'Tunceli', 'Muş', 'Bitlis', 'Siirt',
      'Şırnak', 'Hakkari', 'Ardahan', 'Kars', 'Adıyaman', 'Osmaniye',
      'Düzce', 'Bartın', 'Kastamonu', 'Çankırı', 'Bolu', 'Bilecik',
      'Kütahya', 'Uşak', 'Şanlıurfa', 'Kilis', 'Gümüşhane', 'Bayburt'
    ];
    
    return cities
        .map((city) => LocationModel(name: city, code: city.toLowerCase()))
        .toList();
  }

  // Fallback ülkeler
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
      LocationModel(name: 'Netherlands', code: 'NL', flag: '🇳🇱'),
      LocationModel(name: 'Belgium', code: 'BE', flag: '🇧🇪'),
      LocationModel(name: 'Switzerland', code: 'CH', flag: '🇨🇭'),
      LocationModel(name: 'Austria', code: 'AT', flag: '🇦🇹'),
      LocationModel(name: 'Portugal', code: 'PT', flag: '🇵🇹'),
    ];
  }

  // Kullanıcının mevcut konumunu tespit et
  Future<LocationModel?> getCurrentLocation() async {
    try {
      debugPrint('Detecting user location via IP...');
      final response = await http.get(
        Uri.parse('http://ip-api.com/json'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final country = data['country'] ?? '';
        final countryCode = data['countryCode'] ?? '';
        
        debugPrint('Detected location: $country ($countryCode)');
        return LocationModel(name: country, code: countryCode);
      }
    } catch (e) {
      debugPrint('Location detection error: $e');
    }
    
    // Fallback: Türkiye
    return LocationModel(name: 'Türkiye', code: 'TR', flag: '🇹🇷');
  }

  // Cache temizle
  void clearCache() {
    _citiesCache.clear();
    _countries.clear();
    _countriesLoaded = false;
    debugPrint('Location cache cleared');
  }
}
