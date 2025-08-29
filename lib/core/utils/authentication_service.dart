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
}
