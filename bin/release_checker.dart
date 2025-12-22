import 'dart:io';

import 'package:flutter_notify/models/release_check_result.dart';
import 'package:flutter_notify/services/backend_service.dart';
import 'package:flutter_notify/services/release_state_service.dart';
import 'package:flutter_notify/services/telegram_service.dart';

Future<void> main(List<String> arguments) async {
  try {
    final localReleaseState = await ReleaseStateService.getLocalReleaseState();
    final result = await ReleaseStateService.getLatestReleases(localReleaseState.etag);

    switch (result) {
      case NoUpdate():
        final verboselyNotifyAdmin = Platform.environment['VERBOSELY_NOTIFY_ADMIN'] == 'true';
        if (verboselyNotifyAdmin) await TelegramService.notifyAdmin('No new releases found');
      case Updated(state: final state):
        await ReleaseStateService.writeState(state);
        final newReleases = ReleaseStateService.getSortedReleasesDiff(localReleaseState.releases, state.releases);
        final notificationtext = ReleaseStateService.getFormattedReleasesText(newReleases);
        await BackendService.notifyUsers(notificationtext);
    }
  } catch (e) {
    await TelegramService.notifyAdmin('🚨 Error: $e');
    rethrow;
  }
}
