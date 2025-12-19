import 'dart:convert';
import 'dart:io';

import 'package:flutter_releases/db/schema.dart';

class TelegramService {
  const TelegramService._();

  static Future<void> notifyAdmin(String message) async {
    final adminChatId = Platform.environment['ADMIN_CHAT_ID'];
    if (adminChatId == null) throw 'ADMIN_CHAT_ID is not set';
    await notifyUser(int.parse(adminChatId), message);
  }

  static Future<void> notifyUser(int chatId, String message) async {
    final telegramBotToken = Platform.environment['TELEGRAM_BOT_TOKEN'];
    if (telegramBotToken == null) throw 'TELEGRAM_BOT_TOKEN is not set';

    final client = HttpClient();

    try {
      final request = await client.postUrl(Uri.parse('https://api.telegram.org/bot$telegramBotToken/sendMessage'));
      final payload = json.encode({'chat_id': chatId, 'text': getEscapedText(message), 'parse_mode': 'MarkdownV2'});

      request
        ..headers.set('Content-Type', 'application/json')
        ..add(utf8.encode(payload));

      final response = await request.close();

      if (response.statusCode != 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final errorData = json.decode(responseBody) as Map<String, dynamic>;
        throw 'Telegram API error: ${errorData['description']} (${response.statusCode})';
      }

      await response.drain();
    } catch (e) {
      stderr.writeln('Failed to send message to chatId $chatId: $e');
      rethrow;
    } finally {
      client.close();
    }
  }

  static Future<void> notifyUsers(List<int> chatIds, String message) async {
    for (final chatId in chatIds) {
      await notifyUser(chatId, message);
    }
  }

  static String buildStatusMessage(ChatId user) {
    final buffer = StringBuffer()
      ..writeln('📅 Joined: ${_formatDate(user.joinedAt)}')
      ..writeln('Your subscription status:\n')
      ..writeln(user.notificationsEnabled ? '✅ Notifications: Enabled' : '❌ Notifications: Disabled');
    if (!user.notificationsEnabled) buffer.writeln('\nHit /start to re-enable notifications.');
    return buffer.toString();
  }

  static String getHelpMessage() => '''
🫡 Available commands:

/start - Enable notifications for Flutter SDK releases
/stop - Disable notifications
/status - Check your notification status
/help - Show this help message
''';

  static String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static String getEscapedText(String text) {
    const specialChars = ['_', '[', ']', '(', ')', '~', '`', '>', '#', '+', '-', '=', '|', '{', '}', '.', '!'];

    var escaped = text;
    for (final char in specialChars) {
      escaped = escaped.replaceAll(char, '\\$char');
    }

    return escaped;
  }
}
