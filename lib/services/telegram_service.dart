import 'dart:convert';
import 'dart:io';

import 'package:flutter_notify/db/schema.dart';
import 'package:flutter_notify/services/database_service.dart';

class TelegramService {
  TelegramService();

  final _client = HttpClient();
  final _botToken = Platform.environment['TELEGRAM_BOT_TOKEN'] ?? (throw StateError('TELEGRAM_BOT_TOKEN not set'));

  Future<void> notifyAdmin(String message) async {
    final adminChatId = Platform.environment['ADMIN_CHAT_ID'];
    if (adminChatId == null) throw 'ADMIN_CHAT_ID is not set';
    await notifyUser(int.parse(adminChatId), message);
  }

  Future<void> notifyUsers(List<int> chatIds, String message) async {
    const batchSize = 25;
    const delayBetweenBatches = Duration(milliseconds: 1100);

    for (var i = 0; i < chatIds.length; i += batchSize) {
      final batch = chatIds.skip(i).take(batchSize);
      await Future.wait(batch.map((chatId) => notifyUser(chatId, message)));
      if (i + batchSize < chatIds.length) await Future.delayed(delayBetweenBatches);
    }
  }

  Future<void> notifyUser(int chatId, String message, {Map<String, dynamic>? replyMarkup}) async {
    try {
      final request = await _client.postUrl(Uri.parse('https://api.telegram.org/bot$_botToken/sendMessage'));
      final payload = json.encode({
        'chat_id': chatId,
        'text': _getEscapedText(message),
        'parse_mode': 'MarkdownV2',
        if (replyMarkup != null) 'reply_markup': replyMarkup,
      });

      request
        ..headers.set('Content-Type', 'application/json')
        ..add(utf8.encode(payload));

      final response = await request.close();
      final statusCode = response.statusCode;

      if (statusCode == 403) {
        stderr.writeln('Bot was likely blocked by user with chatId $chatId. Unsubscribing user.');
        await DatabaseService().unsubscribeUser(chatId);
        stdout.writeln('User with chatId $chatId unsubscribed successfully.');
      } else if (statusCode != 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final errorData = json.decode(responseBody) as Map<String, dynamic>;
        throw 'Status code $statusCode: ${errorData['description']} (${response.statusCode})';
      }

      await response.drain();
    } catch (e) {
      stderr.writeln('Failed to send message to chatId $chatId: $e');
    }
  }

  Future<void> answerCallbackQuery(String callbackQueryId) async {
    try {
      final request = await _client.postUrl(Uri.parse('https://api.telegram.org/bot$_botToken/answerCallbackQuery'));
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

  static String _getEscapedText(String text) {
    const specialChars = ['_', '[', ']', '(', ')', '~', '>', '#', '+', '-', '=', '|', '{', '}', '.', '!'];

    var escaped = text;
    for (final char in specialChars) {
      escaped = escaped.replaceAll(char, '\\$char');
    }

    return escaped;
  }
}
