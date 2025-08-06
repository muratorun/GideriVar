import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../services/ads_service.dart';

class BannerAdWidget extends StatefulWidget {
  final AdSize adSize;
  final EdgeInsets? margin;
  
  const BannerAdWidget({
    super.key,
    this.adSize = AdSize.banner,
    this.margin,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    final adsService = context.read<AdsService>();
    
    _bannerAd = adsService.createBannerAd(
      adSize: widget.adSize,
      onAdLoaded: (ad) {
        if (mounted) {
          setState(() {
            _isAdLoaded = true;
          });
        }
      },
      onAdFailedToLoad: (ad, error) {
        if (mounted) {
          setState(() {
            _isAdLoaded = false;
          });
        }
      },
    );
    
    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink(); // Ad yüklenene kadar boş alan
    }

    return Container(
      margin: widget.margin,
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}

// Rewarded Ad için yardımcı sınıf
class RewardedAdHelper {
  static Future<void> showRewardedAd(
    BuildContext context, {
    required VoidCallback onRewardEarned,
    VoidCallback? onAdClosed,
  }) async {
    final adsService = context.read<AdsService>();
    
    // Ad gösterme sıklığını kontrol et
    if (!adsService.canShowAd()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen biraz bekleyin...'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Loading dialog göster
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final rewardedAd = await adsService.loadRewardedAd();
      
      // Loading dialog'u kapat
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (rewardedAd != null) {
        adsService.showRewardedAd(
          rewardedAd,
          onUserEarnedReward: (ad, reward) {
            debugPrint('User earned reward: ${reward.amount} ${reward.type}');
            onRewardEarned();
            adsService.markAdShown();
          },
          onAdDismissedFullScreenContent: (ad) {
            onAdClosed?.call();
          },
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reklam şu anda kullanılamıyor'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      // Loading dialog'u kapat
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reklam yüklenirken hata oluştu: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
