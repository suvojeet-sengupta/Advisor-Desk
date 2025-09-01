import 'dart:async';
import 'package:http/http.dart' as http;

class AdBlockerService {
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
