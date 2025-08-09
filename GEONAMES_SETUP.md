# GeoNames API Setup Rehberi

Bu uygulama artık dünya çapında şehirler ve ilçeler için **GeoNames API** kullanıyor.

## GeoNames API Nedir?

GeoNames, dünya çapında 11 milyondan fazla yer adı içeren ücretsiz bir coğrafi veritabanıdır.

### Özellikler:
- ✅ **Ücretsiz** (günlük 1000 request limiti)
- ✅ **250+ ülke** ve tüm şehirleri
- ✅ **Şehirler ve ilçeler** için detaylı veri
- ✅ **Caching** sistemi ile performans
- ✅ **Fallback** sistemi ile güvenilirlik

## Kurulum

### 1. GeoNames Hesabı Oluştur (Opsiyonel ama Önerilir)

```
1. http://www.geonames.org/login adresine git
2. Ücretsiz hesap oluştur
3. Email'ini doğrula
4. Username'ini location_service.dart dosyasına ekle
```

### 2. Location Service'te Username Güncelle

```dart
// lib/services/location_service.dart
static const String _geoNamesUsername = 'BURAYA_KENDI_USERNAMENI_YAZ';
```

### 3. Demo Hesap Limitleri

Demo hesabı ile günde **1000 request** yapabilirsin. Kendi hesabın ile **20,000 request**.

## API Endpoints

### Şehirler İçin:
```
http://api.geonames.org/searchJSON?country=TR&featureClass=P&maxRows=1000&username=demo
```

### İlçeler İçin:
```
http://api.geonames.org/searchJSON?name=Istanbul&country=TR&featureClass=A&featureCode=ADM3&maxRows=100&username=demo
```

## Kullanım

### 1. Ülkeye Göre Şehirler:
```dart
final cities = await LocationService().getCitiesByCountry('TR');
print('${cities.length} şehir bulundu');
```

### 2. Şehre Göre İlçeler:
```dart
final districts = await LocationService().getDistrictsByCity('istanbul');
print('${districts.length} ilçe bulundu');
```

## Cache Sistemi

- Şehirler ülke koduna göre cache'lenir
- İlçeler şehir adına göre cache'lenir
- Cache bellekte tutulur, uygulama kapanınca silinir

## Fallback Sistemi

API çalışmazsa:
1. **Türkiye** için → Comprehensive manuel liste
2. **Diğer ülkeler** için → Popüler şehirler listesi

## Performance Tips

1. **İlk yükleme** biraz yavaş olabilir (API call)
2. **Sonraki yüklemeler** çok hızlı (cache'den)
3. **Offline** durumda fallback listesi kullanılır

## Troubleshooting

### GeoNames API çalışmıyorsa:
```
- Demo hesabı limit aşılmış olabilir
- İnternet bağlantısını kontrol et
- Fallback sistemi otomatik devreye girer
```

### Kendi hesap oluşturursan:
```
- Günlük 20,000 request hakkın olur
- Daha güvenilir servis
- Email doğrulaması gerekir
```

## Gelecek Geliştirmeler

- [ ] **Administrative boundaries** (sınırlar)
- [ ] **Population** bilgisi
- [ ] **Coordinates** (enlem/boylam)
- [ ] **Time zones**
- [ ] **Persistent cache** (SQLite)

## Desteklenen Ülkeler

**Tüm dünya ülkeleri** desteklenir! Örnekler:
- 🇹🇷 Türkiye (81 il + tüm ilçeler)
- 🇺🇸 ABD (50 eyalet + şehirler)
- 🇩🇪 Almanya (tüm şehirler)
- 🇫🇷 Fransa (tüm şehirler)
- 🇬🇧 İngiltere (tüm şehirler)
- 🇮🇹 İtalya (tüm şehirler)
- Ve daha fazlası...

Bu sistem sayesinde artık **manuel olarak şehir/ilçe tanımlamanıza gerek yok!** 🎉
