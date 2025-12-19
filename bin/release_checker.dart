import 'dart:io';

import 'package:flutter_releases/models/release_check_result.dart';
import 'package:flutter_releases/services/backend_service.dart';
import 'package:flutter_releases/services/local_state_service.dart';
import 'package:flutter_releases/services/telegram_service.dart';

Future<void> main(List<String> arguments) async {
  try {
    const localStateService = LocalStateService();
    final localReleaseState = await localStateService.getLocalReleaseState();
    final result = await localStateService.getFlutterReleases(localReleaseState.etag);

    switch (result) {
      case NoUpdate():
        final verboselyNotifyAdmin = Platform.environment['VERBOSELY_NOTIFY_ADMIN'] == 'true';
        if (verboselyNotifyAdmin) await TelegramService.notifyAdmin('No new releases found');
      case Updated(state: final state)
          when localStateService.areReleasesIdentical(localReleaseState.releases, state.releases):
        await TelegramService.notifyAdmin('⚠️ States are identical although result marked as Updated.');
      case Updated(state: final state):
        await localStateService.writeState(state);
        final newReleasesText = localStateService.getNewReleasesText(localReleaseState.releases, state.releases);
        await BackendService.notifyUsers(newReleasesText);
    }
  } catch (e) {
    await TelegramService.notifyAdmin('🚨 Error: $e');
  }
}
