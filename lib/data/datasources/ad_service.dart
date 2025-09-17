import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// A service for managing interstitial ads using the Google Mobile Ads SDK.
///
/// This class handles loading and showing interstitial ads. It ensures that a new
/// ad is pre-loaded after one is shown.
class AdService {
  InterstitialAd? _interstitialAd;
  final _adUnitId = 'ca-app-pub-4208901337652644/4365478115';

  /// Loads an interstitial ad.
  ///
  /// This method requests a new ad from the ad server. The ad is stored
  /// internally and can be shown later using the [showAd] method.
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

  /// Shows the loaded interstitial ad.
  ///
  /// If an ad is loaded, it will be displayed in full screen. After the ad is
  /// dismissed or fails to show, a new ad is automatically loaded.
  ///
  /// Returns a [Future] that completes when the ad is dismissed or fails to show.
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
