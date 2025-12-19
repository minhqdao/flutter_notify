import 'dart:convert';
import 'dart:io';

class BackendService {
  const BackendService._();

  static String get _backendUrl {
    final backendUrl = Platform.environment['BACKEND_URL'];
    if (backendUrl == null) throw Exception('BACKEND_URL is not set');
    return backendUrl;
  }

  static Future<void> notifyUsers(String message) async {
    final cronSecret = Platform.environment['CRON_SECRET'];
    if (cronSecret == null) throw Exception('CRON_SECRET is not set');

    final client = HttpClient();

    try {
      final request = await client.postUrl(Uri.parse('$_backendUrl/notify-users'));

      request
        ..headers.set('Content-Type', 'text/plain; charset=utf-8')
        ..headers.set('X-Cron-Secret', cronSecret)
        ..write(message);

      final response = await request.close();

      if (response.statusCode == 200) {
        stdout.writeln('Notifications sent successfully.');
        await response.drain();
      } else {
        final errorBody = await response.transform(utf8.decoder).join();
        throw Exception('Failed with status: ${response.statusCode}. Body: $errorBody');
      }
    } catch (e) {
      stderr.writeln('Error during HTTP request: $e');
      rethrow;
    } finally {
      client.close();
    }
  }
}
