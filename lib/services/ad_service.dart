import 'package:flutter/material.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  // Reklam servisini başlat
  Future<void> initialize() async {
    try {
      // AdMob SDK entegrasyonu eklenecek
      await Future.delayed(const Duration(seconds: 1)); // Simülasyon
      _isInitialized = true;
      debugPrint('Ad Service initialized');
    } catch (e) {
      debugPrint('Ad Service initialization error: $e');
    }
  }

  // Rewarded Ad göster
  Future<bool> showRewardedAd() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      
      // Rewarded Ad gösterme simülasyonu
      await Future.delayed(const Duration(seconds: 3)); // Reklam süresi simülasyonu
      
      // Kullanıcının reklamı tamamladığını simüle et
      return true; // Reklam başarıyla izlendi
    } catch (e) {
      debugPrint('Rewarded ad error: $e');
      return false;
    }
  }

  // Banner Ad göster
  Widget? getBannerAd() {
    if (!_isInitialized) return null;
    
    // Banner Ad widget'ı - Firebase entegrasyonunda değiştirilecek
    return Container(
      height: 50,
      color: Colors.grey[300],
      child: const Center(
        child: Text(
          'Banner Reklam Alanı',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  // Interstitial Ad göster
  Future<void> showInterstitialAd() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      
      // Interstitial Ad gösterme simülasyonu
      await Future.delayed(const Duration(seconds: 2));
      debugPrint('Interstitial ad shown');
    } catch (e) {
      debugPrint('Interstitial ad error: $e');
    }
  }

  // Reklam yüklenmeyi kontrol et
  Future<bool> isRewardedAdReady() async {
    // Reklam hazır mı kontrolü - simüle edildi
    return _isInitialized;
  }

  void dispose() {
    // Reklam kaynaklarını temizle
    _isInitialized = false;
  }
}
