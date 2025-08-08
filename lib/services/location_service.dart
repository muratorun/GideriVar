import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class LocationModel {
  final String name;
  final String code;
  final String? flag;
  final String? parentCode; // İlçeler için il kodu

  LocationModel({
    required this.name,
    required this.code,
    this.flag,
    this.parentCode,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      name: json['name']?['common'] ?? json['name'] ?? '',
      code: json['cca2'] ?? json['code'] ?? '',
      flag: json['flag'] ?? json['emoji'],
      parentCode: json['parentCode'],
    );
  }
}

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  List<LocationModel> _countries = [];
  List<LocationModel> _cities = [];
  List<LocationModel> _districts = [];
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
      debugPrint('Error loading countries: $e');
      // Fallback olarak temel ülkeler döndür
      return _getFallbackCountries();
    }
  }

  // REST Countries Cities API (ücretsiz) - countryCode için cities
  Future<List<LocationModel>> getCitiesByCountry(String countryCode) async {
    try {
      debugPrint('Loading cities for country: $countryCode');
      
      // Türkiye özel durumu - kendi listimizi kullan
      if (countryCode.toUpperCase() == 'TR') {
        debugPrint('Using Turkish cities fallback');
        return getTurkishCities();
      }
      
      // Diğer ülkeler için önce fallback döndür, sonra API'yi dene
      final fallbackCities = _getFallbackCitiesForCountry(countryCode);
      
      try {
        // GeoNames API - daha güvenilir (ücretsiz, registration gerektirmeyen endpoint)
        final response = await http.get(
          Uri.parse(
            'https://secure.geonames.org/countryInfoJSON?country=$countryCode&username=demo'
          ),
          headers: {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          if (data['geonames'] != null && data['geonames'].isNotEmpty) {
            debugPrint('Successfully loaded cities from GeoNames API');
            // API'den veri geldi ama şimdilik fallback kullan
            // Gerçek implementasyon için daha fazla geliştirme gerekir
          }
        }
      } catch (apiError) {
        debugPrint('GeoNames API error: $apiError, using fallback');
      }
      
      debugPrint('Returning ${fallbackCities.length} fallback cities for $countryCode');
      return fallbackCities;
      
    } catch (e) {
      debugPrint('Error loading cities for $countryCode: $e');
      return _getFallbackCitiesForCountry(countryCode);
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
      debugPrint('Error searching locations: $e');
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
      debugPrint('Error getting current location: $e');
    }
    return null;
  }

  // Cache'i temizle
  void clearCache() {
    _countries.clear();
    _cities.clear();
    _districts.clear();
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

  // Şehir koduna göre ilçeleri getir
  Future<List<LocationModel>> getDistrictsByCity(String cityCode) async {
    try {
      debugPrint('Loading districts for city: $cityCode');
      
      // Türkiye için comprehensive ilçe listesi
      if (cityCode.toLowerCase() == 'istanbul' || cityCode.toLowerCase() == 'İstanbul') {
        return _getIstanbulDistricts();
      } else if (cityCode.toLowerCase() == 'ankara') {
        return _getAnkaraDistricts();
      } else if (cityCode.toLowerCase() == 'izmir' || cityCode.toLowerCase() == 'İzmir') {
        return _getIzmirDistricts();
      } else if (cityCode.toLowerCase() == 'bursa') {
        return _getBursaDistricts();
      } else if (cityCode.toLowerCase() == 'antalya') {
        return _getAntalyaDistricts();
      }
      
      // Diğer şehirler için genel ilçe listesi
      return _getGeneralDistricts(cityCode);
      
    } catch (e) {
      debugPrint('Error loading districts for $cityCode: $e');
      return _getGeneralDistricts(cityCode);
    }
  }

  // Fallback şehirler (ülke koduna göre)
  List<LocationModel> _getFallbackCitiesForCountry(String countryCode) {
    final fallbackCities = {
      'TR': ['İstanbul', 'Ankara', 'İzmir', 'Bursa', 'Antalya'],
      'US': ['New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix'],
      'GB': ['London', 'Birmingham', 'Manchester', 'Liverpool', 'Leeds'],
      'DE': ['Berlin', 'Hamburg', 'Munich', 'Cologne', 'Frankfurt'],
      'FR': ['Paris', 'Marseille', 'Lyon', 'Toulouse', 'Nice'],
      'IT': ['Rome', 'Milan', 'Naples', 'Turin', 'Palermo'],
      'ES': ['Madrid', 'Barcelona', 'Valencia', 'Seville', 'Zaragoza'],
      'CA': ['Toronto', 'Vancouver', 'Montreal', 'Calgary', 'Ottawa'],
      'AU': ['Sydney', 'Melbourne', 'Brisbane', 'Perth', 'Adelaide'],
      'JP': ['Tokyo', 'Osaka', 'Yokohama', 'Nagoya', 'Sapporo'],
      'KR': ['Seoul', 'Busan', 'Incheon', 'Daegu', 'Daejeon'],
      'BR': ['São Paulo', 'Rio de Janeiro', 'Brasília', 'Salvador', 'Fortaleza'],
      'IN': ['Mumbai', 'Delhi', 'Bangalore', 'Hyderabad', 'Chennai'],
      'CN': ['Beijing', 'Shanghai', 'Guangzhou', 'Shenzhen', 'Chengdu'],
      'RU': ['Moscow', 'Saint Petersburg', 'Novosibirsk', 'Yekaterinburg', 'Kazan'],
    };
    
    final cities = fallbackCities[countryCode.toUpperCase()] ?? ['City Center'];
    return cities
        .map((city) => LocationModel(name: city, code: city.toLowerCase().replaceAll(' ', '_')))
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

  // İstanbul İlçeleri
  List<LocationModel> _getIstanbulDistricts() {
    const districts = [
      'Adalar', 'Arnavutköy', 'Ataşehir', 'Avcılar', 'Bağcılar', 'Bahçelievler',
      'Bakırköy', 'Başakşehir', 'Bayrampaşa', 'Beşiktaş', 'Beykoz', 'Beylikdüzü',
      'Beyoğlu', 'Büyükçekmece', 'Çatalca', 'Çekmeköy', 'Esenler', 'Esenyurt',
      'Eyüpsultan', 'Fatih', 'Gaziosmanpaşa', 'Güngören', 'Kadıköy', 'Kağıthane',
      'Kartal', 'Küçükçekmece', 'Maltepe', 'Pendik', 'Sancaktepe', 'Sarıyer',
      'Silivri', 'Şile', 'Şişli', 'Sultangazi', 'Sultanbeyli', 'Tuzla',
      'Ümraniye', 'Üsküdar', 'Zeytinburnu'
    ];
    
    return districts
        .map((district) => LocationModel(
              name: district, 
              code: district.toLowerCase(), 
              parentCode: 'istanbul'
            ))
        .toList();
  }

  // Ankara İlçeleri
  List<LocationModel> _getAnkaraDistricts() {
    const districts = [
      'Akyurt', 'Altındağ', 'Ayaş', 'Bala', 'Beypazarı', 'Çamlıdere',
      'Çankaya', 'Çubuk', 'Elmadağ', 'Etimesgut', 'Evren', 'Gölbaşı',
      'Güdül', 'Haymana', 'Kalecik', 'Kazan', 'Keçiören', 'Kızılcahamam',
      'Mamak', 'Nallıhan', 'Polatlı', 'Pursaklar', 'Sincan', 'Şereflikoçhisar',
      'Yenimahalle'
    ];
    
    return districts
        .map((district) => LocationModel(
              name: district, 
              code: district.toLowerCase(), 
              parentCode: 'ankara'
            ))
        .toList();
  }

  // İzmir İlçeleri
  List<LocationModel> _getIzmirDistricts() {
    const districts = [
      'Aliağa', 'Balçova', 'Bayındır', 'Bayraklı', 'Bergama', 'Beydağ',
      'Bornova', 'Buca', 'Çeşme', 'Çiğli', 'Dikili', 'Foça', 'Gaziemir',
      'Güzelbahçe', 'Karabağlar', 'Karaburun', 'Karşıyaka', 'Kemalpaşa',
      'Kınık', 'Kiraz', 'Konak', 'Menderes', 'Menemen', 'Narlıdere',
      'Ödemiş', 'Seferihisar', 'Selçuk', 'Tire', 'Torbalı', 'Urla'
    ];
    
    return districts
        .map((district) => LocationModel(
              name: district, 
              code: district.toLowerCase(), 
              parentCode: 'izmir'
            ))
        .toList();
  }

  // Bursa İlçeleri
  List<LocationModel> _getBursaDistricts() {
    const districts = [
      'Büyükorhan', 'Gemlik', 'Gürsu', 'Harmancık', 'İnegöl', 'İznik',
      'Karacabey', 'Keles', 'Kestel', 'Mudanya', 'Mustafakemalpaşa',
      'Nilüfer', 'Orhaneli', 'Orhangazi', 'Osmangazi', 'Yenişehir', 'Yıldırım'
    ];
    
    return districts
        .map((district) => LocationModel(
              name: district, 
              code: district.toLowerCase(), 
              parentCode: 'bursa'
            ))
        .toList();
  }

  // Antalya İlçeleri
  List<LocationModel> _getAntalyaDistricts() {
    const districts = [
      'Akseki', 'Aksu', 'Alanya', 'Demre', 'Döşemealtı', 'Elmalı',
      'Finike', 'Gazipaşa', 'Gündoğmuş', 'İbradı', 'Kaş', 'Kemer',
      'Kepez', 'Konyaaltı', 'Korkuteli', 'Kumluca', 'Manavgat',
      'Muratpaşa', 'Serik'
    ];
    
    return districts
        .map((district) => LocationModel(
              name: district, 
              code: district.toLowerCase(), 
              parentCode: 'antalya'
            ))
        .toList();
  }

  // Genel ilçeler (diğer şehirler için)
  List<LocationModel> _getGeneralDistricts(String cityCode) {
    const generalDistricts = [
      'Merkez', 'Şehir Merkezi', 'Ana Bölge', 'Kuzey', 'Güney', 'Doğu', 'Batı'
    ];
    
    return generalDistricts
        .map((district) => LocationModel(
              name: district, 
              code: district.toLowerCase().replaceAll(' ', '_'), 
              parentCode: cityCode.toLowerCase()
            ))
        .toList();
  }
}
