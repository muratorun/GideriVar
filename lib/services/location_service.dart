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

  // API URLs
  static const String _restCountriesUrl = 'https://restcountries.com/v3.1/all';
  static const String _geoNamesUrl = 'http://api.geonames.org';
  static const String _geoNamesUsername = 'demo'; // Kendi GeoNames hesabınızı oluşturun
  
  // Cache
  List<LocationModel> _countries = [];
  List<LocationModel> _cities = [];
  Map<String, List<LocationModel>> _cachedCities = {};
  Map<String, List<LocationModel>> _cachedDistricts = {};
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
      print('Error loading countries: $e');
      // Fallback olarak temel ülkeler döndür
      return _getFallbackCountries();
    }
  }

  // GeoNames API ile ülkeye göre şehirleri getir (yeni gelişmiş metod)
  Future<List<LocationModel>> getCitiesFromGeoNames(String countryCode) async {
    try {
      // Cache kontrol et
      if (_cachedCities.containsKey(countryCode)) {
        print('Using cached cities for $countryCode');
        return _cachedCities[countryCode]!;
      }

      // GeoNames API - Places (cities) endpoint
      final url = '$_geoNamesUrl/searchJSON?country=$countryCode&featureClass=P&maxRows=1000&username=$_geoNamesUsername';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['geonames'] != null) {
          final geonames = data['geonames'] as List;
          
          final cities = geonames.map((item) => LocationModel(
            name: item['name'] ?? '',
            code: (item['name'] ?? '').toString().toLowerCase().replaceAll(' ', '_'),
            parentCode: countryCode.toLowerCase(),
          )).toList();
          
          // Duplicates'i temizle ve sırala
          final uniqueCities = <String, LocationModel>{};
          for (final city in cities) {
            if (city.name.isNotEmpty && !uniqueCities.containsKey(city.name)) {
              uniqueCities[city.name] = city;
            }
          }
          
          final result = uniqueCities.values.toList()
            ..sort((a, b) => a.name.compareTo(b.name));
          
          // Cache'e kaydet
          _cachedCities[countryCode] = result;
          print('Loaded ${result.length} cities for $countryCode from GeoNames');
          return result;
        }
      }
      
      print('GeoNames API returned no data for $countryCode');
      return [];
      
    } catch (e) {
      print('Error fetching cities from GeoNames: $e');
      return [];
    }
  }

  // GeoNames API ile şehre göre ilçeleri getir (yeni gelişmiş metod)
  Future<List<LocationModel>> getDistrictsFromGeoNames(String cityName, String countryCode) async {
    try {
      final cacheKey = '${countryCode}_$cityName';
      
      // Cache kontrol et
      if (_cachedDistricts.containsKey(cacheKey)) {
        print('Using cached districts for $cityName');
        return _cachedDistricts[cacheKey]!;
      }

      // GeoNames API - Administrative divisions (districts)
      final url = '$_geoNamesUrl/searchJSON?name=$cityName&country=$countryCode&featureClass=A&featureCode=ADM3&maxRows=100&username=$_geoNamesUsername';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['geonames'] != null) {
          final geonames = data['geonames'] as List;
          
          final districts = geonames.map((item) => LocationModel(
            name: item['name'] ?? '',
            code: (item['name'] ?? '').toString().toLowerCase().replaceAll(' ', '_'),
            parentCode: cityName.toLowerCase(),
          )).toList();
          
          // Duplicates'i temizle ve sırala
          final uniqueDistricts = <String, LocationModel>{};
          for (final district in districts) {
            if (district.name.isNotEmpty && !uniqueDistricts.containsKey(district.name)) {
              uniqueDistricts[district.name] = district;
            }
          }
          
          final result = uniqueDistricts.values.toList()
            ..sort((a, b) => a.name.compareTo(b.name));
          
          // Cache'e kaydet
          _cachedDistricts[cacheKey] = result;
          print('Loaded ${result.length} districts for $cityName from GeoNames');
          return result;
        }
      }
      
      print('GeoNames API returned no districts for $cityName');
      return [];
      
    } catch (e) {
      print('Error fetching districts from GeoNames: $e');
      return [];
    }
  }

  // REST Countries Cities API (ücretsiz) - countryCode için cities
  Future<List<LocationModel>> getCitiesByCountry(String countryCode) async {
    try {
      print('Loading cities for country: $countryCode');
      
      // Önce GeoNames API'den dene
      final geoNamesCities = await getCitiesFromGeoNames(countryCode);
      if (geoNamesCities.isNotEmpty) {
        return geoNamesCities;
      }
      
      // Türkiye için özel fallback
      if (countryCode.toUpperCase() == 'TR') {
        print('Using Turkish cities fallback');
        return getTurkishCities();
      }
      
      // Diğer ülkeler için genel fallback
      print('Using fallback cities for $countryCode');
      return _getFallbackCitiesForCountry(countryCode);
      
    } catch (e) {
      print('Error loading cities for $countryCode: $e');
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

  // Türkiye'nin tüm 81 ili
  List<LocationModel> getTurkishCities() {
    const cities = [
      // A
      'Adana', 'Adıyaman', 'Afyonkarahisar', 'Ağrı', 'Amasya', 'Ankara', 'Antalya', 'Artvin', 'Aydın',
      // B
      'Balıkesir', 'Bartın', 'Batman', 'Bayburt', 'Bilecik', 'Bingöl', 'Bitlis', 'Bolu', 'Burdur', 'Bursa',
      // C
      'Çanakkale', 'Çankırı', 'Çorum',
      // D
      'Denizli', 'Diyarbakır', 'Düzce',
      // E
      'Edirne', 'Elazığ', 'Erzincan', 'Erzurum', 'Eskişehir',
      // G
      'Gaziantep', 'Giresun', 'Gümüşhane',
      // H
      'Hakkari', 'Hatay',
      // I
      'Iğdır', 'Isparta', 'İstanbul', 'İzmir',
      // K
      'Kahramanmaraş', 'Karabük', 'Karaman', 'Kars', 'Kastamonu', 'Kayseri', 'Kırıkkale', 'Kırklareli', 'Kırşehir', 'Kilis', 'Kocaeli', 'Konya', 'Kütahya',
      // M
      'Malatya', 'Manisa', 'Mardin', 'Mersin', 'Muğla', 'Muş',
      // N
      'Nevşehir', 'Niğde',
      // O
      'Ordu', 'Osmaniye',
      // R
      'Rize',
      // S
      'Sakarya', 'Samsun', 'Siirt', 'Sinop', 'Sivas', 'Şanlıurfa', 'Şırnak',
      // T
      'Tekirdağ', 'Tokat', 'Trabzon', 'Tunceli',
      // U
      'Uşak',
      // V
      'Van',
      // Y
      'Yalova', 'Yozgat',
      // Z
      'Zonguldak',
    ];
    
    return cities
        .map((city) => LocationModel(name: city, code: city.toLowerCase().replaceAll('ş', 's').replaceAll('ı', 'i').replaceAll('ğ', 'g').replaceAll('ü', 'u').replaceAll('ö', 'o').replaceAll('ç', 'c')))
        .toList();
  }

  // Türkiye illeri ve ilçeleri - Comprehensive data structure
  static const Map<String, List<String>> _turkishProvinceDistricts = {
    'adana': ['Aladağ', 'Ceyhan', 'Çukurova', 'Feke', 'İmamoğlu', 'Karaisalı', 'Karataş', 'Kozan', 'Pozantı', 'Saimbeyli', 'Sarıçam', 'Seyhan', 'Tufanbeyli', 'Yumurtalık', 'Yüreğir'],
    'adiyaman': ['Besni', 'Çelikhan', 'Gerger', 'Gölbaşı', 'Kahta', 'Merkez', 'Samsat', 'Sincik', 'Tut'],
    'afyonkarahisar': ['Bolvadin', 'Çay', 'Çobanlar', 'Dazkırı', 'Dinar', 'Emirdağ', 'Evciler', 'Hocalar', 'İhsaniye', 'İscehisar', 'Kızılören', 'Merkez', 'Sandıklı', 'Sinanpaşa', 'Sultandağı', 'Şuhut'],
    'agri': ['Diyadin', 'Doğubayazıt', 'Eleşkirt', 'Hamur', 'Merkez', 'Patnos', 'Taşlıçay', 'Tutak'],
    'amasya': ['Göynücek', 'Gümüşhacıköy', 'Hamamözü', 'Merkez', 'Merzifon', 'Suluova', 'Taşova'],
    'ankara': ['Akyurt', 'Altındağ', 'Ayaş', 'Bala', 'Beypazarı', 'Çamlıdere', 'Çankaya', 'Çubuk', 'Elmadağ', 'Etimesgut', 'Evren', 'Gölbaşı', 'Güdül', 'Haymana', 'Kalecik', 'Kazan', 'Keçiören', 'Kızılcahamam', 'Mamak', 'Nallıhan', 'Polatlı', 'Pursaklar', 'Sincan', 'Şereflikoçhisar', 'Yenimahalle'],
    'antalya': ['Akseki', 'Aksu', 'Alanya', 'Demre', 'Döşemealtı', 'Elmalı', 'Finike', 'Gazipaşa', 'Gündoğmuş', 'İbradı', 'Kas', 'Kemer', 'Kepez', 'Konyaaltı', 'Korkuteli', 'Kumluca', 'Manavgat', 'Muratpaşa', 'Serik'],
    'artvin': ['Ardanuç', 'Arhavi', 'Borçka', 'Hopa', 'Merkez', 'Murgul', 'Şavşat', 'Yusufeli'],
    'aydin': ['Bozdoğan', 'Buharkent', 'Çine', 'Didim', 'Efeler', 'Germencik', 'İncirliova', 'Karacasu', 'Karpuzlu', 'Koçarlı', 'Köşk', 'Kuşadası', 'Kuyucak', 'Nazilli', 'Söke', 'Sultanhisar', 'Yenipazar'],
    'balikesir': ['Altıeylül', 'Ayvalık', 'Balya', 'Bandırma', 'Bigadiç', 'Burhaniye', 'Dursunbey', 'Edremit', 'Erdek', 'Gömeç', 'Gönen', 'Havran', 'İvrindi', 'Karesi', 'Kepsut', 'Manyas', 'Marmara', 'Savaştepe', 'Sındırgı', 'Susurluk'],
    'bartin': ['Amasra', 'Kurucaşile', 'Merkez', 'Ulus'],
    'batman': ['Beşiri', 'Gercüş', 'Hasankeyf', 'Kozluk', 'Merkez', 'Sason'],
    'bayburt': ['Aydıntepe', 'Demirözü', 'Merkez'],
    'bilecik': ['Bozüyük', 'Gölpazarı', 'İnhisar', 'Merkez', 'Osmaneli', 'Pazaryeri', 'Söğüt', 'Yenipazar'],
    'bingol': ['Adaklı', 'Genç', 'Karlıova', 'Kiğı', 'Merkez', 'Solhan', 'Yayladere', 'Yedisu'],
    'bitlis': ['Adilcevaz', 'Ahlat', 'Güroymak', 'Hizan', 'Merkez', 'Mutki', 'Tatvan'],
    'bolu': ['Dörtdivan', 'Gerede', 'Göynük', 'Kıbrıscık', 'Mengen', 'Merkez', 'Mudurnu', 'Seben', 'Yeniçağa'],
    'burdur': ['Ağlasun', 'Altınyayla', 'Bucak', 'Çavdır', 'Çeltikçi', 'Gölhisar', 'Karamanlı', 'Kemer', 'Merkez', 'Tefenni', 'Yeşilova'],
    'bursa': ['Büyükorhan', 'Gemlik', 'Gürsu', 'Harmancık', 'İnegöl', 'İznik', 'Karacabey', 'Keles', 'Kestel', 'Mudanya', 'Mustafakemalpaşa', 'Nilüfer', 'Orhaneli', 'Orhangazi', 'Osmangazi', 'Yenişehir', 'Yıldırım'],
    'canakkale': ['Ayvacık', 'Bayramiç', 'Biga', 'Bozcaada', 'Çan', 'Eceabat', 'Ezine', 'Gelibolu', 'Gökçeada', 'Lapseki', 'Merkez', 'Yenice'],
    'cankiri': ['Atkaracalar', 'Bayramören', 'Çerkeş', 'Eldivan', 'Ilgaz', 'Kızılırmak', 'Korgun', 'Kurşunlu', 'Merkez', 'Orta', 'Şabanözü', 'Yapraklı'],
    'corum': ['Alaca', 'Bayat', 'Boğazkale', 'Dodurga', 'İskilip', 'Kargı', 'Laçin', 'Mecitözü', 'Merkez', 'Oğuzlar', 'Ortaköy', 'Osmancık', 'Sungurlu', 'Uğurludağ'],
    'denizli': ['Acıpayam', 'Babadağ', 'Baklan', 'Bekilli', 'Beyağaç', 'Bozkurt', 'Buldan', 'Çal', 'Çameli', 'Çardak', 'Çivril', 'Güney', 'Honaz', 'Kale', 'Merkezefendi', 'Pamukkale', 'Sarayköy', 'Serinhisar', 'Tavas'],
    'diyarbakir': ['Bağlar', 'Bismil', 'Çermik', 'Çınar', 'Çüngüş', 'Dicle', 'Eğil', 'Ergani', 'Hani', 'Hazro', 'Kayapınar', 'Kocaköy', 'Kulp', 'Lice', 'Silvan', 'Sur', 'Yenişehir'],
    'duzce': ['Akçakoca', 'Cumayeri', 'Çilimli', 'Gölyaka', 'Gümüşova', 'Kaynaşlı', 'Merkez', 'Yığılca'],
    'edirne': ['Enez', 'Havsa', 'İpsala', 'Keşan', 'Lalapaşa', 'Meriç', 'Merkez', 'Süloğlu', 'Uzunköprü'],
    'elazig': ['Ağın', 'Alacakaya', 'Arıcak', 'Baskil', 'Karakoçan', 'Keban', 'Kovancılar', 'Maden', 'Merkez', 'Palu', 'Sivrice'],
    'erzincan': ['Çayırlı', 'İliç', 'Kemah', 'Kemaliye', 'Merkez', 'Otlukbeli', 'Refahiye', 'Tercan', 'Üzümlü'],
    'erzurum': ['Aşkale', 'Aziziye', 'Çat', 'Hınıs', 'Horasan', 'İspir', 'Karaçoban', 'Karayazı', 'Köprüköy', 'Narman', 'Oltu', 'Olur', 'Palandöken', 'Pasinler', 'Pazaryolu', 'Şenkaya', 'Tekman', 'Tortum', 'Uzundere', 'Yakutiye'],
    'eskisehir': ['Alpu', 'Beylikova', 'Çifteler', 'Günyüzü', 'Han', 'İnönü', 'Mahmudiye', 'Mihalgazi', 'Mihalıççık', 'Odunpazarı', 'Sarıcakaya', 'Seyitgazi', 'Sivrihisar', 'Tepebaşı'],
    'gaziantep': ['Araban', 'İslahiye', 'Karkamış', 'Nizip', 'Nurdağı', 'Oğuzeli', 'Şahinbey', 'Şehitkamil', 'Yavuzeli'],
    'giresun': ['Alucra', 'Bulancak', 'Çamoluk', 'Çanakçı', 'Dereli', 'Doğankent', 'Espiye', 'Eynesil', 'Görele', 'Güce', 'Keşap', 'Merkez', 'Piraziz', 'Şebinkarahisar', 'Tirebolu', 'Yağlıdere'],
    'gumushane': ['Kelkit', 'Köse', 'Kürtün', 'Merkez', 'Şiran', 'Torul'],
    'hakkari': ['Çukurca', 'Derecik', 'Merkez', 'Şemdinli', 'Yüksekova'],
    'hatay': ['Altınözü', 'Antakya', 'Arsuz', 'Belen', 'Defne', 'Dörtyol', 'Erzin', 'Hassa', 'İskenderun', 'Kırıkhan', 'Kumlu', 'Payas', 'Reyhanlı', 'Samandağ', 'Yayladağı'],
    'igdir': ['Aralık', 'Karakoyunlu', 'Merkez', 'Tuzluca'],
    'isparta': ['Aksu', 'Atabey', 'Eğirdir', 'Gelendost', 'Gönen', 'Keçiborlu', 'Merkez', 'Senirkent', 'Sütçüler', 'Şarkikaraağaç', 'Uluborlu', 'Yalvaç', 'Yenişarbademli'],
    'istanbul': ['Adalar', 'Arnavutköy', 'Ataşehir', 'Avcılar', 'Bağcılar', 'Bahçelievler', 'Bakırköy', 'Başakşehir', 'Bayrampaşa', 'Beşiktaş', 'Beykoz', 'Beylikdüzü', 'Beyoğlu', 'Büyükçekmece', 'Çatalca', 'Çekmeköy', 'Esenler', 'Esenyurt', 'Eyüpsultan', 'Fatih', 'Gaziosmanpaşa', 'Güngören', 'Kadıköy', 'Kağıthane', 'Kartal', 'Küçükçekmece', 'Maltepe', 'Pendik', 'Sancaktepe', 'Sarıyer', 'Silivri', 'Sultanbeyli', 'Sultangazi', 'Şile', 'Şişli', 'Tuzla', 'Ümraniye', 'Üsküdar', 'Zeytinburnu'],
    'izmir': ['Aliağa', 'Balçova', 'Bayındır', 'Bayraklı', 'Bergama', 'Beydağ', 'Bornova', 'Buca', 'Çeşme', 'Çiğli', 'Dikili', 'Foça', 'Gaziemir', 'Güzelbahçe', 'Karabağlar', 'Karaburun', 'Karşıyaka', 'Kemalpaşa', 'Kınık', 'Kiraz', 'Konak', 'Menderes', 'Menemen', 'Narlıdere', 'Ödemiş', 'Seferihisar', 'Selçuk', 'Tire', 'Torbalı', 'Urla'],
    'kahramanmaras': ['Afşin', 'Andırın', 'Çağlayancerit', 'Dulkadiroğlu', 'Ekinözü', 'Elbistan', 'Göksun', 'Nurhak', 'Onikişubat', 'Pazarcık', 'Türkoğlu'],
    'karabuk': ['Eflani', 'Eskipazar', 'Merkez', 'Ovacık', 'Safranbolu', 'Yenice'],
    'karaman': ['Ayrancı', 'Başyayla', 'Ermenek', 'Kazımkarabekir', 'Merkez', 'Sarıveliler'],
    'kars': ['Akyaka', 'Arpaçay', 'Digor', 'Kağızman', 'Merkez', 'Sarıkamış', 'Selim', 'Susuz'],
    'kastamonu': ['Abana', 'Ağlı', 'Araç', 'Azdavay', 'Bozkurt', 'Cide', 'Çatalzeytin', 'Daday', 'Devrekani', 'Doğanyurt', 'Hanönü', 'İhsangazi', 'İnebolu', 'Küre', 'Merkez', 'Pınarbaşı', 'Seydiler', 'Şenpazar', 'Taşköprü', 'Tosya'],
    'kayseri': ['Akkışla', 'Bünyan', 'Develi', 'Felahiye', 'Hacılar', 'İncesu', 'Kocasinan', 'Melikgazi', 'Özvatan', 'Pınarbaşı', 'Sarıoğlan', 'Sarız', 'Talas', 'Tomarza', 'Yahyalı', 'Yeşilhisar'],
    'kirikkale': ['Bahşılı', 'Balışeyh', 'Çelebi', 'Delice', 'Karakeçili', 'Keskin', 'Merkez', 'Sulakyurt', 'Yahşihan'],
    'kirklareli': ['Babaeski', 'Demirköy', 'Kofçaz', 'Lüleburgaz', 'Merkez', 'Pehlivanköy', 'Pınarhisar', 'Vize'],
    'kirsehir': ['Akçakent', 'Akpınar', 'Boztepe', 'Çiçekdağı', 'Kaman', 'Merkez', 'Mucur'],
    'kilis': ['Elbeyli', 'Merkez', 'Musabeyli', 'Polateli'],
    'kocaeli': ['Başiskele', 'Çayırova', 'Darıca', 'Derince', 'Dilovası', 'Gebze', 'Gölcük', 'İzmit', 'Kandıra', 'Karamürsel', 'Kartepe', 'Körfez'],
    'konya': ['Ahırlı', 'Akören', 'Akşehir', 'Altınekin', 'Beyşehir', 'Bozkır', 'Cihanbeyli', 'Çeltik', 'Çumra', 'Derbent', 'Derebucak', 'Doğanhisar', 'Emirgazi', 'Ereğli', 'Güneysınır', 'Hadim', 'Halkapınar', 'Hüyük', 'Ilgın', 'Kadınhanı', 'Karapınar', 'Karatay', 'Kulu', 'Meram', 'Sarayönü', 'Selçuklu', 'Seydişehir', 'Taşkent', 'Tuzlukçu', 'Yalıhüyük', 'Yunak'],
    'kutahya': ['Altıntaş', 'Aslanapa', 'Çavdarhisar', 'Domaniç', 'Dumlupınar', 'Emet', 'Gediz', 'Hisarcık', 'Merkez', 'Pazarlar', 'Simav', 'Şaphane', 'Tavşanlı'],
    'malatya': ['Akçadağ', 'Arapgir', 'Arguvan', 'Battalgazi', 'Darende', 'Doğanşehir', 'Doğanyol', 'Hekimhan', 'Kale', 'Kuluncak', 'Pütürge', 'Yazihan', 'Yeşilyurt'],
    'manisa': ['Ahmetli', 'Akhisar', 'Alaşehir', 'Demirci', 'Gölmarmara', 'Gördes', 'Kırkağaç', 'Köprübaşı', 'Kula', 'Merkez', 'Salihli', 'Sarıgöl', 'Saruhanlı', 'Selendi', 'Soma', 'Şehzadeler', 'Turgutlu', 'Yunusemre'],
    'mardin': ['Artuklu', 'Dargeçit', 'Derik', 'Kızıltepe', 'Mazıdağı', 'Midyat', 'Nusaybin', 'Ömerli', 'Savur', 'Yeşilli'],
    'mersin': ['Akdeniz', 'Anamur', 'Aydıncık', 'Bozyazı', 'Çamlıyayla', 'Erdemli', 'Gülnar', 'Mezitli', 'Mut', 'Silifke', 'Tarsus', 'Toroslar', 'Yenişehir'],
    'mugla': ['Bodrum', 'Dalaman', 'Datça', 'Fethiye', 'Kavaklıdere', 'Köyceğiz', 'Marmaris', 'Menteşe', 'Milas', 'Ortaca', 'Seydikemer', 'Ula', 'Yatağan'],
    'mus': ['Bulanık', 'Hasköy', 'Korkut', 'Malazgirt', 'Merkez', 'Varto'],
    'nevsehir': ['Acıgöl', 'Avanos', 'Derinkuyu', 'Gülşehir', 'Hacıbektaş', 'Kozaklı', 'Merkez', 'Ürgüp'],
    'nigde': ['Altunhisar', 'Bor', 'Çamardı', 'Çiftlik', 'Merkez', 'Ulukışla'],
    'ordu': ['Akkuş', 'Altınordu', 'Aybastı', 'Çamaş', 'Çatalpınar', 'Çaybaşı', 'Fatsa', 'Gölköy', 'Gülyalı', 'Gürgentepe', 'İkizce', 'Kabadüz', 'Kabataş', 'Korgan', 'Kumru', 'Mesudiye', 'Perşembe', 'Ulubey', 'Ünye'],
    'osmaniye': ['Bahçe', 'Düziçi', 'Hasanbeyli', 'Kadirli', 'Merkez', 'Sumbas', 'Toprakkale'],
    'rize': ['Ardeşen', 'Çamlıhemşin', 'Çayeli', 'Derepazarı', 'Fındıklı', 'Güneysu', 'Hemşin', 'İkizdere', 'İyidere', 'Kalkandere', 'Merkez', 'Pazar'],
    'sakarya': ['Adapazarı', 'Akyazı', 'Arifiye', 'Erenler', 'Ferizli', 'Geyve', 'Hendek', 'Karapürçek', 'Karasu', 'Kaynarca', 'Kocaali', 'Pamukova', 'Sapanca', 'Serdivan', 'Söğütlü', 'Taraklı'],
    'samsun': ['19 Mayıs', 'Alaçam', 'Asarcık', 'Atakum', 'Ayvacık', 'Bafra', 'Canik', 'Çarşamba', 'Havza', 'İlkadım', 'Kavak', 'Ladik', 'Ondokuzmayıs', 'Salıpazarı', 'Tekkeköy', 'Terme', 'Vezirköprü', 'Yakakent'],
    'siirt': ['Aydınlar', 'Baykan', 'Eruh', 'Kurtalan', 'Merkez', 'Pervari', 'Şirvan'],
    'sinop': ['Ayancık', 'Boyabat', 'Dikmen', 'Durağan', 'Erfelek', 'Gerze', 'Merkez', 'Saraydüzü', 'Türkeli'],
    'sivas': ['Akıncılar', 'Altınyayla', 'Divriği', 'Doğanşar', 'Gemerek', 'Gölova', 'Gürün', 'Hafik', 'İmranlı', 'Kangal', 'Koyulhisar', 'Merkez', 'Suşehri', 'Şarkışla', 'Ulaş', 'Yıldızeli', 'Zara'],
    'sanliurfa': ['Akçakale', 'Birecik', 'Bozova', 'Ceylanpınar', 'Eyyübiye', 'Halfeti', 'Haliliye', 'Harran', 'Hilvan', 'Karaköprü', 'Siverek', 'Suruç', 'Viranşehir'],
    'sirnak': ['Beytüşşebap', 'Cizre', 'Güçlükonak', 'İdil', 'Merkez', 'Silopi', 'Uludere'],
    'tekirdag': ['Çerkezköy', 'Çorlu', 'Ergene', 'Hayrabolu', 'Kapaklı', 'Malkara', 'Marmaraereğlisi', 'Muratlı', 'Saray', 'Süleymanpaşa', 'Şarköy'],
    'tokat': ['Almus', 'Artova', 'Başçiftlik', 'Erbaa', 'Merkez', 'Niksar', 'Pazar', 'Reşadiye', 'Sulusaray', 'Turhal', 'Yeşilyurt', 'Zile'],
    'trabzon': ['Akçaabat', 'Araklı', 'Arsin', 'Beşikdüzü', 'Çarşıbaşı', 'Çaykara', 'Dernekpazarı', 'Düzköy', 'Hayrat', 'Köprübaşı', 'Maçka', 'Of', 'Ortahisar', 'Sürmene', 'Şalpazarı', 'Tonya', 'Vakfıkebir', 'Yomra'],
    'tunceli': ['Çemişgezek', 'Hozat', 'Mazgirt', 'Merkez', 'Nazımiye', 'Ovacık', 'Pertek', 'Pülümür'],
    'usak': ['Banaz', 'Eşme', 'Karahallı', 'Merkez', 'Sivaslı', 'Ulubey'],
    'van': ['Bahçesaray', 'Başkale', 'Çaldıran', 'Çatak', 'Edremit', 'Erciş', 'Gevaş', 'Gürpınar', 'İpekyolu', 'Muradiye', 'Özalp', 'Saray', 'Tuşba'],
    'yalova': ['Altınova', 'Armutlu', 'Çınarcık', 'Çiftlikköy', 'Merkez', 'Termal'],
    'yozgat': ['Akdağmadeni', 'Aydıncık', 'Boğazlıyan', 'Çandır', 'Çayıralan', 'Çekerek', 'Kadışehri', 'Merkez', 'Saraykent', 'Sarıkaya', 'Şefaatli', 'Sorgun', 'Yenifakılı', 'Yerköy'],
    'zonguldak': ['Alaplı', 'Çaycuma', 'Devrek', 'Gökçebey', 'Kilimli', 'Kozlu', 'Merkez'],
  };

  // Şehir koduna göre ilçeleri getir
  Future<List<LocationModel>> getDistrictsByCity(String cityCode) async {
    try {
      print('Loading districts for city: $cityCode');
      
      // Önce GeoNames API'den dene (cityCode'u cityName olarak kullan)
      final geoNamesDistricts = await getDistrictsFromGeoNames(cityCode, 'TR'); // Default olarak TR
      if (geoNamesDistricts.isNotEmpty) {
        return geoNamesDistricts;
      }
      
      // Türk karakterlerini normalize et
      final normalizedCityCode = cityCode.toLowerCase()
          .replaceAll('ş', 's')
          .replaceAll('ı', 'i')
          .replaceAll('ğ', 'g')
          .replaceAll('ü', 'u')
          .replaceAll('ö', 'o')
          .replaceAll('ç', 'c');
      
      // Türkiye için comprehensive ilçe listesinden getir
      final districtNames = _turkishProvinceDistricts[normalizedCityCode];
      if (districtNames != null) {
        return districtNames
            .map((districtName) => LocationModel(
                  name: districtName,
                  code: districtName.toLowerCase(),
                  parentCode: normalizedCityCode,
                ))
            .toList();
      }
      
      // Diğer ülkeler için boş liste döndür
      return [];
      
    } catch (e) {
      print('Error loading districts for $cityCode: $e');
      return [];
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

}
