import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A service that handles user authentication, including biometrics and PIN.
///
/// This class provides methods to check for biometric availability, perform
/// biometric authentication, verify a PIN, and manage app lock settings.
class AuthenticationService {
  static final _auth = LocalAuthentication();

  /// Checks if biometric authentication is available on the device.
  ///
  /// Returns `true` if the device supports biometrics (e.g., fingerprint, face ID)
  /// and has biometrics enrolled. Otherwise, returns `false`.
  static Future<bool> isBiometricAvailable() async {
    final isAvailable = await _auth.canCheckBiometrics;
    final isDeviceSupported = await _auth.isDeviceSupported();
    return isAvailable && isDeviceSupported;
  }

  /// Attempts to authenticate the user using biometrics.
  ///
  /// This will display a system dialog prompting the user for their fingerprint
  /// or face.
  ///
  /// Returns `true` if authentication is successful, `false` otherwise.
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

  /// Verifies if the provided [pin] matches the one stored in [SharedPreferences].
  ///
  /// The [pin] is the PIN entered by the user.
  /// Returns `true` if the PIN is correct, `false` otherwise.
  static Future<bool> checkPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString('app_pin');
    return savedPin == pin;
  }

  /// Checks if the app lock feature is enabled.
  ///
  /// Returns `true` if app lock is enabled, `false` otherwise.
  static Future<bool> isAppLockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isAppLockEnabled') ?? false;
  }

  /// Updates the last successful authentication timestamp to the current time.
  ///
  /// This is used to determine if re-authentication is required based on the timeout setting.
  static Future<void> updateLastAuthenticationTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_authentication_time', DateTime.now().millisecondsSinceEpoch);
  }

  /// Determines if authentication is required based on the configured timeout.
  ///
  /// This method checks the time elapsed since the last successful authentication
  /// and compares it with the user-defined timeout setting.
  ///
  /// Returns `true` if authentication is required, `false` otherwise.
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
