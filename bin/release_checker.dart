import 'dart:io';

import 'package:flutter_notify/models/release_check_result.dart';
import 'package:flutter_notify/services/backend_service.dart';
import 'package:flutter_notify/services/release_state_service.dart';
import 'package:flutter_notify/services/telegram_service.dart';

Future<void> main(List<String> arguments) async {
  try {
    final localReleaseState = await ReleaseStateService.getLocalReleaseState();
    stdout.writeln('${localReleaseState.releases.length} releases read from local state.');
    final result = await ReleaseStateService.getAllFlutterReleases(localReleaseState.etag);

    switch (result) {
      case NoUpdate():
        stdout.writeln('No new releases found. Aborting.');
        final verboselyNotifyAdmin = Platform.environment['VERBOSELY_NOTIFY_ADMIN'] == 'true';
        if (verboselyNotifyAdmin) await TelegramService().notifyAdmin('No new releases found');
      case Updated(state: final state):
        stdout.writeln('New release(s) found!');
        await ReleaseStateService.writeState(state);
        stdout.writeln('Local state updated with ${state.releases.length} releases and etag ${state.etag}.');
        final newReleases = ReleaseStateService.getSortedReleasesDiff(localReleaseState.releases, state.releases);
        final notificationtext = ReleaseStateService.getNewReleasesText(newReleases);
        stdout.writeln(notificationtext);
        await BackendService.notifyUsers(notificationtext);
    }
  } catch (e) {
    stderr.writeln('Error: $e');
    await TelegramService().notifyAdmin('🚨 Error: $e');
    rethrow;
  }
}
