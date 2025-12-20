import 'dart:io';

import 'package:flutter_releases/models/release_check_result.dart';
import 'package:flutter_releases/services/backend_service.dart';
import 'package:flutter_releases/services/release_state_service.dart';
import 'package:flutter_releases/services/telegram_service.dart';

Future<void> main(List<String> arguments) async {
  try {
    const releaseStateService = ReleaseStateService();
    final localReleaseState = await releaseStateService.getLocalReleaseState();
    final result = await releaseStateService.getFlutterReleases(localReleaseState.etag);

    switch (result) {
      case NoUpdate():
        final verboselyNotifyAdmin = Platform.environment['VERBOSELY_NOTIFY_ADMIN'] == 'true';
        if (verboselyNotifyAdmin) await TelegramService.notifyAdmin('No new releases found');
      case Updated(state: final state):
        await releaseStateService.writeState(state);
        final newReleasesText = releaseStateService.getNewReleasesText(localReleaseState.releases, state.releases);
        await BackendService.notifyUsers(newReleasesText);
    }
  } catch (e) {
    await TelegramService.notifyAdmin('🚨 Error: $e');
  }
}
