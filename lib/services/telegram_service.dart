import 'dart:io';

import 'package:flutter_releases/db/schema.dart';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';

class TelegramService {
  const TelegramService._();

  static Future<void> notifyAdmin(String message) async {
    final adminChatId = Platform.environment['ADMIN_CHAT_ID'];
    if (adminChatId == null) throw Exception('ADMIN_CHAT_ID is not set');
    await notifyUser(int.parse(adminChatId), message);
  }

  static Future<void> notifyUser(int chatId, String message) async {
    final telegramBotToken = Platform.environment['TELEGRAM_BOT_TOKEN'];
    if (telegramBotToken == null) throw Exception('TELEGRAM_BOT_TOKEN is not set');

    final username = (await Telegram(telegramBotToken).getMe()).username;
    final teledart = TeleDart(telegramBotToken, Event(username!));
    teledart.start();

    try {
      await teledart.sendMessage(chatId, getEscapedText(message), parseMode: 'MarkdownV2');
    } finally {
      teledart.stop();
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
