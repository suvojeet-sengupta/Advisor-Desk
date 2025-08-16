import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class DetailsScreenBannerAd extends StatefulWidget {
  const DetailsScreenBannerAd({Key? key}) : super(key: key);

  @override
  _DetailsScreenBannerAdState createState() => _DetailsScreenBannerAdState();
}

class _DetailsScreenBannerAdState extends State<DetailsScreenBannerAd> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  final adUnitId = 'ca-app-pub-4208901337652644/6416926381';

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoaded
        ? SizedBox(
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          )
        : const SizedBox.shrink();
  }
}
