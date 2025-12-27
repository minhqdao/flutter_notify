import 'dart:convert';
import 'dart:io';
import 'package:deep_pick/deep_pick.dart';
import 'package:flutter_notify/enums/channel.dart';
import 'package:flutter_notify/models/release_check_result.dart';
import 'package:flutter_notify/services/database_service.dart';
import 'package:flutter_notify/services/release_state_service.dart';
import 'package:flutter_notify/services/telegram_service.dart';
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

      final callbackQuery = pick(data, 'callback_query').asMapOrNull();
      if (callbackQuery != null) {
        final callbackData = pick(callbackQuery, 'data').asStringOrThrow();
        final chatId = pick(callbackQuery, 'message', 'chat', 'id').asIntOrThrow();
        final callbackQueryId = pick(callbackQuery, 'id').asStringOrThrow();

        switch (callbackData) {
          case 'latest_stable':
          case 'latest_beta':
            final channel = callbackData == 'latest_stable' ? Channel.stable : Channel.beta;
            final result = await ReleaseStateService.getAllFlutterReleases();

            switch (result) {
              case NoUpdate():
                throw 'The NoUpdate case should never be reached';
              case Updated(state: final state):
                final releases = ReleaseStateService.getReleasesByChannel(state.releases, channel);
                final reversed = releases.take(15).toList().reversed;

                final header = '*Latest `${channel.name}` Flutter Releases:*';
                final releasesLines = reversed
                    .map((r) => '• *${r.version}* • ${ReleaseStateService.getFormattedDate(r.date)}')
                    .toList();

                await TelegramService.notifyUser(chatId, '$header\n\n${releasesLines.join('\n')}');
                stdout.writeln('Sent ${channel.name} releases to chatId $chatId');
            }
        }

        await TelegramService.answerCallbackQuery(callbackQueryId);
        return Response.ok('OK');
      }

      final message = pick(data, 'message').asMapOrNull();

      if (message == null) {
        stderr.writeln('Missing or invalid webhook message.');
        return Response.ok('Missing or invalid webhook message.');
      }

      final text = pick(message, 'text').asStringOrThrow();
      final chatId = pick(message, 'chat', 'id').asIntOrThrow();
      final textParts = text.split(RegExp(r'\s+'));
      final command = textParts[0];

      switch (command) {
        case '/start':
          final source = textParts.length > 1 ? textParts[1].trim() : null;
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
            "You won't receive Flutter SDK release alerts anymore. Send /start anytime to re-enable.",
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
        case '/latest':
          final result = await ReleaseStateService.getAllFlutterReleases();
          switch (result) {
            case NoUpdate():
              throw 'The NoUpdate case should never be reached';
            case Updated(state: final state):
              final unsortedReleases = [
                ...ReleaseStateService.getLatestRelease(state.releases, Channel.stable, 1),
                ...ReleaseStateService.getLatestRelease(state.releases, Channel.beta, 1),
              ];
              final releases = ReleaseStateService.sortByDescendingVersion(unsortedReleases);

              const header = '*Latest Flutter Releases:*';
              final newReleasesLines = releases
                  .map(
                    (r) => '• `${r.channel.name}` • *${r.version}* • ${ReleaseStateService.getFormattedDate(r.date)}',
                  )
                  .toList();

              await TelegramService.notifyUser(
                chatId,
                '$header\n\n${newReleasesLines.join('\n')}\n\nChoose channel so see more releases 👇',
                replyMarkup: {
                  'inline_keyboard': [
                    [
                      {'text': 'Stable', 'callback_data': 'latest_stable'},
                      {'text': 'Beta', 'callback_data': 'latest_beta'},
                    ],
                  ],
                },
              );
              stdout.writeln('Sent latest releases with reply markup to chatId $chatId');
          }
        default:
          stdout.writeln('Unknown command: $text');
          await TelegramService.notifyUser(chatId, 'Unknown command: $text');
      }

      return Response.ok('OK');
    } catch (e) {
      stderr.writeln('Error processing webhook: $e');
      TelegramService.notifyAdmin('🚨 Error processing webhook: $e');
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
