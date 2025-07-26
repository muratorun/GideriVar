# 🌍 Giderivar - Global Marketplace App

Giderivar artık global bir pazaryeri uygulamasıdır! Türkiye'deki kullanıcılarla sınırlı kalmayıp dünya çapında kullanıcılara hizmet verebilir.

## 🗺️ Global Location System

### Özellikler:
- **Dinamik Ülke Listesi**: REST Countries API'den gerçek zamanlı ülke verisi
- **Şehir/Bölge Desteği**: GeoDB Cities API ile şehir bilgileri
- **IP Tabanlı Konum**: Kullanıcının mevcut konumunu otomatik tespit
- **Fallback Sistem**: API erişimi olmadığında yerel veriler
- **Çoklu Dil Desteği**: Kategori ve UI elementleri için çeviri sistemi

### Kullanılan API'ler:

#### 1. REST Countries API (Ücretsiz)
```
https://restcountries.com/v3.1/all?fields=name,cca2,flag
```
- Tüm ülkeler ve bayrakları
- Rate limit: Yok
- API Key: Gerekli değil

#### 2. GeoDB Cities API (Freemium)
```
https://wft-geo-db.p.rapidapi.com/v1/geo/countries/{countryCode}/places
```
- Şehir/bölge bilgileri
- Rate limit: 10 req/sec, 1000 req/day (ücretsiz plan)
- API Key: RapidAPI key gerekli

#### 3. Nominatim OpenStreetMap (Ücretsiz)
```
https://nominatim.openstreetmap.org/search
```
- Konum arama
- Rate limit: 1 req/sec
- API Key: Gerekli değil

#### 4. IP Geolocation (Ücretsiz)
```
https://ipapi.co/json/
```
- Mevcut konum tespiti
- Rate limit: 1000 req/month
- API Key: Gerekli değil

## 🚀 Kurulum

### 1. API Key'leri Yapılandırma

`lib/utils/constants.dart` dosyasında API key'lerinizi güncelleyin:

```dart
class AppConstants {
  // API Keys
  static const String rapidApiKey = 'YOUR_RAPIDAPI_KEY_HERE';
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY_HERE';
  
  // Location Settings
  static const bool useOnlineLocationService = true; // false yaparak offline moda geçebilirsiniz
}
```

### 2. RapidAPI Key Alma
1. [RapidAPI](https://rapidapi.com/)'ye kayıt olun
2. [GeoDB Cities API](https://rapidapi.com/wirefreethought/api/geodb-cities/)'yi subscribe edin
3. API key'inizi kopyalayın
4. Constants dosyasına ekleyin

### 3. Paket Kurulumu
```bash
flutter pub get
```

## 🌐 Desteklenen Lokasyonlar

### Online Mod (useOnlineLocationService: true)
- **240+ Ülke**: REST Countries API'den
- **100,000+ Şehir**: GeoDB Cities API'den
- **Otomatik Konum**: IP tabanlı tespit
- **Gerçek Zamanlı**: API'lerden güncel veri

### Offline Mod (useOnlineLocationService: false)
- **15 Ana Bölge**: Fallback regions
- **Türkiye Şehirleri**: 32 büyük şehir
- **Sabit Liste**: Lokal tanımlı kategoriler

## 📱 Kullanım

### Home Tab - Ürün Filtreleme
```dart
// Kullanıcı ülke seçer
_selectedCountry = "United States";

// Sistem otomatik olarak o ülkenin şehirlerini yükler
await LocationService().getCitiesByCountry("US");

// Filtrelenmiş ürünler gösterilir
products = await DatabaseService().getProductsByRegion(_selectedRegion);
```

### Add Product - Konum Seçimi
```dart
// Mevcut konumu otomatik tespit et
final currentLocation = await LocationService().getCurrentLocation();

// Kullanıcı ülke/şehir seçebilir
_selectedCountry = "Germany";
_selectedRegion = "Berlin";
```

### Çoklu Dil Desteği
```dart
// Kategori çevirisi
String localizedCategory = _getLocalizedCategory("Electronics");
// Türkçe: "Elektronik"
// İspanyolca: "Electrónicos"
// İngilizce: "Electronics"
```

## ⚙️ Konfigürasyon

### 1. API Rate Limit Yönetimi
```dart
// GeoDB Cities API limiti aşılırsa fallback kullan
try {
  final cities = await LocationService().getCitiesByCountry(countryCode);
} catch (e) {
  // Fallback: Türkiye şehirleri
  cities = LocationService().getTurkishCities();
}
```

### 2. Cache Sistemi
```dart
// Ülkeler bir kez yüklenip cache'lenir
if (_countriesLoaded) return _countries;

// Cache'i temizlemek için
LocationService().clearCache();
```

### 3. Hata Yönetimi
```dart
// Ağ hatalarında fallback regions kullanılır
final countries = await LocationService().getCountries();
// Hata durumunda: ['Global', 'North America', 'Europe', ...]
```

## 🎯 Global Pazaryeri Özellikleri

### Ülke Bazında Kategoriler
- Elektronik → Electronics / Elektronik / Electrónicos
- Giyim → Fashion / Giyim / Moda
- Ev & Bahçe → Home & Garden

### Bölgesel Filtreleme
- Ülke seçimi → Şehir listesi yüklenir
- Mevcut konum tespiti → Otomatik bölge seçimi
- Global arama → Tüm bölgeler

### Çok Dilli Destek
- UI elementleri lokalize edilebilir
- Kategori çevirileri hazır
- Yeni diller kolayca eklenebilir

## 🚨 Önemli Notlar

### API Limitleri
- **GeoDB Cities**: 1000 req/day (ücretsiz)
- **Nominatim**: 1 req/second
- **ipapi.co**: 1000 req/month

### Fallback Stratejisi
1. Online API'ler öncelikli
2. Hata durumunda yerel data
3. Türkiye için özel fallback
4. Global bölgeler her zaman mevcut

### Production Hazırlığı
- API key'leri environment variable'lardan alın
- Error tracking ekleyin (Sentry, Crashlytics)
- Analytics entegrasyonu (Firebase Analytics)
- Kullanıcı lokasyonu için permission yönetimi

## 📈 Genişletme Önerileri

### 1. Gelişmiş Konum Servisleri
```dart
// location package ile GPS entegrasyonu
import 'package:location/location.dart';

final location = Location();
final currentLocation = await location.getLocation();
```

### 2. Offline Maps
```dart
// google_maps_flutter ile harita entegrasyonu
import 'package:google_maps_flutter/google_maps_flutter.dart';
```

### 3. Çoklu Dil UI
```dart
// flutter_localizations ile tam lokalizasyon
import 'package:flutter_localizations/flutter_localizations.dart';
```

### 4. Machine Learning
```dart
// Kullanıcı davranışına göre konum önerisi
// Firebase ML Kit ile konum analizi
```

## 🌟 Sonuç

Giderivar artık global bir pazaryeri! Herhangi bir ülkeden kullanıcılar:
- Kendi ülkelerini seçebilir
- Şehir bazında filtreleme yapabilir  
- Yerel dilde kategorileri görüntüleyebilir
- Otomatik konum tespiti ile hızlı başlayabilir

Bu sistem sayesinde uygulamanız sadece Türkiye ile sınırlı kalmayıp dünya çapında kullanılabilir! 🚀
