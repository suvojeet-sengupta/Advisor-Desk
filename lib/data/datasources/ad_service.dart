import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  InterstitialAd? _interstitialAd;
  final _adUnitId = 'ca-app-pub-4208901337652644/4365478115';

  void loadAd() {
    InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  Future<void> showAd() {
    if (_interstitialAd != null) {
      final completer = Completer<void>();
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          loadAd();
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          loadAd();
          if (!completer.isCompleted) {
            completer.completeError(error); // Or just complete() if you don't want to propagate the error
          }
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
      return completer.future;
    }
    return Future.value(); // Return a completed future if no ad is shown
  }
}
