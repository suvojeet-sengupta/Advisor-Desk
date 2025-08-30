import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationService {
  static final _auth = LocalAuthentication();

  static Future<bool> isBiometricAvailable() async {
    final isAvailable = await _auth.canCheckBiometrics;
    final isDeviceSupported = await _auth.isDeviceSupported();
    return isAvailable && isDeviceSupported;
  }

  static Future<bool> authenticateWithBiometrics() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Scan your fingerprint or face to unlock Advisor Desk',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
    } on PlatformException catch (e) {
      print(e); // Handle error
      return false;
    }
  }

  static Future<bool> checkPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString('app_pin');
    return savedPin == pin;
  }

  static Future<bool> isAppLockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isAppLockEnabled') ?? false;
  }

  static Future<void> updateLastAuthenticationTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_authentication_time', DateTime.now().millisecondsSinceEpoch);
  }

  static Future<bool> isAuthenticationRequired() async {
    final prefs = await SharedPreferences.getInstance();
    final timeoutSetting = prefs.getString('authentication_timeout') ?? 'Immediately';

    if (timeoutSetting == 'Immediately') {
      return true;
    }

    final lastAuthTimeMillis = prefs.getInt('last_authentication_time');
    if (lastAuthTimeMillis == null) {
      return true;
    }

    final lastAuthTime = DateTime.fromMillisecondsSinceEpoch(lastAuthTimeMillis);
    final currentTime = DateTime.now();
    final difference = currentTime.difference(lastAuthTime);

    int timeoutMinutes;
    switch (timeoutSetting) {
      case '1_minute':
        timeoutMinutes = 1;
        break;
      case '3_minutes':
        timeoutMinutes = 3;
        break;
      case '5_minutes':
        timeoutMinutes = 5;
        break;
      default:
        timeoutMinutes = 0;
    }

    return difference.inMinutes >= timeoutMinutes;
  }
}
