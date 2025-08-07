import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsService {
  static AdsService? _instance;
  static AdsService get instance => _instance ??= AdsService._internal();
  AdsService._internal();

  // Production Ads IDs (Gerçek AdMob Console'dan alınan)
  static const String _prodBannerAdUnitIdAndroid = 'ca-app-pub-4294862964805642/4426275603';
  static const String _prodBannerAdUnitIdiOS = 'ca-app-pub-4294862964805642/3500174923';
  static const String _prodInterstitialAdUnitIdAndroid = 'ca-app-pub-4294862964805642/1496859937';
  static const String _prodInterstitialAdUnitIdiOS = 'ca-app-pub-4294862964805642/6749186611';
  static const String _prodRewardedAdUnitIdAndroid = 'ca-app-pub-4294862964805642/9275245786';
  static const String _prodRewardedAdUnitIdiOS = 'ca-app-pub-4294862964805642/2809941603';

  // Banner Ad ID
  String get bannerAdUnitId {
    return Platform.isAndroid 
        ? _prodBannerAdUnitIdAndroid 
        : _prodBannerAdUnitIdiOS;
  }

  // Interstitial Ad ID
  String get interstitialAdUnitId {
    return Platform.isAndroid 
        ? _prodInterstitialAdUnitIdAndroid 
        : _prodInterstitialAdUnitIdiOS;
  }

  // Rewarded Ad ID
  String get rewardedAdUnitId {
    return Platform.isAndroid 
        ? _prodRewardedAdUnitIdAndroid 
        : _prodRewardedAdUnitIdiOS;
  }

  // Initialize Mobile Ads SDK
  Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      debugPrint('Mobile Ads initialized successfully');
    } catch (e) {
      debugPrint('Mobile Ads initialization failed: $e');
      rethrow;
    }
  }

  // Banner Ad oluştur
  BannerAd createBannerAd({
    AdSize adSize = AdSize.banner,
    void Function(Ad, LoadAdError)? onAdFailedToLoad,
    void Function(Ad)? onAdLoaded,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('Banner ad loaded: ${ad.adUnitId}');
          onAdLoaded?.call(ad);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad failed to load: ${error.message}');
          ad.dispose();
          onAdFailedToLoad?.call(ad, error);
        },
        onAdOpened: (ad) => debugPrint('Banner ad opened'),
        onAdClosed: (ad) => debugPrint('Banner ad closed'),
      ),
    );
  }

  // Interstitial Ad yükle
  Future<InterstitialAd?> loadInterstitialAd() async {
    InterstitialAd? interstitialAd;
    
    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('Interstitial ad loaded');
          interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial ad failed to load: ${error.message}');
          interstitialAd = null;
        },
      ),
    );
    
    return interstitialAd;
  }

  // Rewarded Ad yükle
  Future<RewardedAd?> loadRewardedAd() async {
    RewardedAd? rewardedAd;
    
    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('Rewarded ad loaded');
          rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded ad failed to load: ${error.message}');
          rewardedAd = null;
        },
      ),
    );
    
    return rewardedAd;
  }

  // Rewarded Ad göster
  void showRewardedAd(
    RewardedAd ad, {
    required void Function(AdWithoutView, RewardItem) onUserEarnedReward,
    void Function(Ad)? onAdDismissedFullScreenContent,
  }) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('Rewarded ad showed full screen content');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('Rewarded ad dismissed full screen content');
        ad.dispose();
        onAdDismissedFullScreenContent?.call(ad);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Rewarded ad failed to show full screen content: ${error.message}');
        ad.dispose();
      },
    );

    ad.show(onUserEarnedReward: onUserEarnedReward);
  }

  // Ad bekleme süresi kontrol et (aynı anda çok fazla ad gösterilmemesi için)
  static DateTime? _lastAdShownTime;
  static const int _adCooldownSeconds = 30; // 30 saniye bekleme

  bool canShowAd() {
    if (_lastAdShownTime == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(_lastAdShownTime!);
    return difference.inSeconds >= _adCooldownSeconds;
  }

  void markAdShown() {
    _lastAdShownTime = DateTime.now();
  }

  // AdMob App ID'leri (Production)
  static const String androidAppId = 'ca-app-pub-4294862964805642~3803427250';
  static const String iosAppId = 'ca-app-pub-4294862964805642~6317909954';
}
