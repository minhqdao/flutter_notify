import 'dart:convert';
import 'dart:io';

import 'package:flutter_notify/db/schema.dart';

class TelegramService {
  const TelegramService._();

  static Future<void> notifyAdmin(String message) async {
    final adminChatId = Platform.environment['ADMIN_CHAT_ID'];
    if (adminChatId == null) throw 'ADMIN_CHAT_ID is not set';
    await notifyUser(int.parse(adminChatId), message);
  }

  static Future<void> notifyUsers(List<int> chatIds, String message) async {
    for (final chatId in chatIds) {
      await notifyUser(chatId, message);
    }
  }

  static Future<void> notifyUser(int chatId, String message, {Map<String, dynamic>? replyMarkup}) async {
    final telegramBotToken = Platform.environment['TELEGRAM_BOT_TOKEN'];
    if (telegramBotToken == null) throw 'TELEGRAM_BOT_TOKEN is not set';

    final client = HttpClient();

    try {
      final request = await client.postUrl(Uri.parse('https://api.telegram.org/bot$telegramBotToken/sendMessage'));
      final payload = json.encode({
        'chat_id': chatId,
        'text': getEscapedText(message),
        'parse_mode': 'MarkdownV2',
        if (replyMarkup != null) 'reply_markup': replyMarkup,
      });

      request
        ..headers.set('Content-Type', 'application/json')
        ..add(utf8.encode(payload));

      final response = await request.close();

      if (response.statusCode != 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final errorData = json.decode(responseBody) as Map<String, dynamic>;
        throw 'Telegram API error sending message: ${errorData['description']} (${response.statusCode})';
      }

      await response.drain();
    } catch (e) {
      stderr.writeln('Failed to send message to chatId $chatId: $e');
      rethrow;
    } finally {
      client.close();
    }
  }

  static Future<void> answerCallbackQuery(String callbackQueryId) async {
    final telegramBotToken = Platform.environment['TELEGRAM_BOT_TOKEN'];
    if (telegramBotToken == null) throw 'TELEGRAM_BOT_TOKEN is not set';

    final client = HttpClient();

    try {
      final request = await client.postUrl(
        Uri.parse('https://api.telegram.org/bot$telegramBotToken/answerCallbackQuery'),
      );
      final payload = json.encode({'callback_query_id': callbackQueryId});

      request
        ..headers.set('Content-Type', 'application/json')
        ..add(utf8.encode(payload));

      final response = await request.close();

      if (response.statusCode != 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final errorData = json.decode(responseBody) as Map<String, dynamic>;
        throw 'Telegram API error answering callback query: ${errorData['description']} (${response.statusCode})';
      }

      await response.drain();
    } catch (e) {
      stderr.writeln('Failed to answer callback query $callbackQueryId: $e');
      rethrow;
    } finally {
      client.close();
    }
  }

  static String buildStatusMessage(ChatId user) {
    final buffer = StringBuffer()
      ..writeln('Your subscription status:\n')
      ..writeln('📅 Joined: ${_formatDate(user.joinedAt)}')
      ..writeln(user.notificationsEnabled ? '✅ Notifications: Enabled' : '❌ Notifications: Disabled');
    if (!user.notificationsEnabled) buffer.writeln('\nHit /start to re-enable notifications.');
    return buffer.toString();
  }

  static String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static String getEscapedText(String text) {
    const specialChars = ['_', '[', ']', '(', ')', '~', '>', '#', '+', '-', '=', '|', '{', '}', '.', '!'];

    var escaped = text;
    for (final char in specialChars) {
      escaped = escaped.replaceAll(char, '\\$char');
    }

    return escaped;
  }
}
