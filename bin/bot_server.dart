import 'dart:convert';
import 'dart:io';
import 'package:deep_pick/deep_pick.dart';
import 'package:flutter_releases/services/database_service.dart';
import 'package:flutter_releases/services/telegram_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

void main() async {
  final router = Router();

  router.post('/telegram-webhook', (Request request) async {
    final configSecret = Platform.environment['TELEGRAM_WEBHOOK_SECRET'];
    if (configSecret == null) {
      stderr.writeln('Webhook secret not set');
      return Response.ok('Webhook secret not set');
    }

    final receivedSecret = request.headers['X-Telegram-Bot-Api-Secret-Token'];
    if (receivedSecret != configSecret) {
      stderr.writeln('Blocked unauthorized webhook attempt.');
      return Response.ok('Unauthorized');
    }

    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);
      final message = pick(data, 'message').asMapOrThrow();
      final text = pick(message, 'text').asStringOrThrow();
      final chatId = pick(message, 'chat', 'id').asIntOrThrow();

      switch (text) {
        case '/start':
          final parts = text.split(' ');
          final source = parts.length > 1 ? parts[1] : null;
          await DatabaseService().registerUser(chatId, source);
          await TelegramService.notifyUser(
            chatId,
            "You're all set! You'll be notified about new Flutter SDK releases 🚀",
          );
          stdout.writeln('Registered user with chatId $chatId from source $source');
        case '/stop':
          await DatabaseService().unsubscribeUser(chatId);
          await TelegramService.notifyUser(
            chatId,
            "I won't send you Flutter SDK release alerts anymore. Send /start anytime to re-enable ✌️",
          );
          stdout.writeln('Unsubscribed user with chatId $chatId');
        case '/status':
          try {
            final user = await DatabaseService().getUserStatus(chatId);
            await TelegramService.notifyUser(chatId, TelegramService.buildStatusMessage(user));
            stdout.writeln('Status check for chatId $chatId');
          } catch (e) {
            await TelegramService.notifyUser(
              chatId,
              "I couldn't find you in the database 🤔 Please use /start to enable notifications.",
            );
            stderr.writeln('Could not find chatId $chatId');
          }
        case '/help':
          await TelegramService.notifyUser(chatId, TelegramService.getHelpMessage());
          stdout.writeln('Sent help message to chatId $chatId');
        default:
          stdout.writeln('Unknown command: $text');
      }

      return Response.ok('OK');
    } catch (e) {
      stderr.writeln('Error processing webhook: $e');
      return Response.ok('😣 An error occurred');
    }
  });

  router.post('/notify-users', (Request request) async {
    final serverSecret = Platform.environment['CRON_SECRET'];
    if (serverSecret == null || serverSecret.isEmpty) {
      stderr.writeln('Server secret not set');
      return Response.internalServerError(body: 'Server configuration error: Missing secret key.');
    }

    final clientSecret = request.headers['X-Cron-Secret'];
    if (clientSecret != serverSecret) {
      stdout.writeln('Unauthorized access attempt');
      return Response.forbidden('Unauthorized');
    }

    final message = await request.readAsString();
    final users = await DatabaseService().getSubscribedUsers();
    await TelegramService.notifyUsers(users, message);
    return Response.ok('OK');
  });

  final handler = const Pipeline().addMiddleware(logRequests()).addHandler(router.call);
  final port = int.tryParse(Platform.environment['PORT'] ?? '8080') ?? 8080;
  final server = await serve(handler, InternetAddress.anyIPv4, port);

  stdout.writeln('Serving at http://${server.address.host}:${server.port}');
}
