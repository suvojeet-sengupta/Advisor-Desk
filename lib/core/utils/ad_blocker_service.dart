import 'dart:async';
import 'package:http/http.dart' as http;

/// A service to detect if an ad blocker is active on the user's device.
///
/// This service works by sending a request to a known ad server endpoint.
/// If the request is blocked or times out, it's likely that an ad blocker is active.
class AdBlockerService {
  /// Checks if an ad blocker is active.
  ///
  /// It tries to send a GET request to a Google Ads endpoint. If the request
  /// fails, times out, or returns a status code other than 200, it assumes an
  /// ad blocker is present.
  ///
  /// Returns `true` if an ad blocker is detected, `false` otherwise.
  Future<bool> isAdBlockerActive() async {
    try {
      final response = await http.get(Uri.parse('https://googleads.g.doubleclick.net')).timeout(const Duration(seconds: 5));
      return response.statusCode != 200;
    } on TimeoutException catch (_) {
      // Timeout likely means the request was blocked.
      return true;
    } on http.ClientException catch (_) {
      // ClientException (e.g., SocketException) can also indicate a blocked request.
      return true;
    } catch (e) {
      // Other exceptions might occur, but we'll assume it's due to an ad blocker.
      return true;
    }
  }
}
