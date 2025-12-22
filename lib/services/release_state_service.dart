import 'dart:convert';
import 'dart:io';

import 'package:flutter_notify/models/release.dart';
import 'package:flutter_notify/models/release_check_result.dart';
import 'package:flutter_notify/models/release_state.dart';
import 'package:flutter_notify/services/telegram_service.dart';
import 'package:pub_semver/pub_semver.dart';

class ReleaseStateService {
  const ReleaseStateService();

  static const _stateFile = '.state/releases.json';
  static const _releaseEndpoint = 'https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json';

  Future<void> resetState() async {
    switch (await getFlutterReleases()) {
      case Updated(state: final state):
        await writeState(state);
      case NoUpdate():
    }
  }

  Future<void> writeState(ReleaseState releaseState) async {
    await File(_stateFile).parent.create(recursive: true);
    final tmpFile = File('$_stateFile.tmp');
    await tmpFile.writeAsString(const JsonEncoder.withIndent('  ').convert(releaseState.toJson()));
    await tmpFile.rename(_stateFile);
  }

  Future<ReleaseState> getLocalReleaseState() async {
    final file = File(_stateFile);
    if (!file.existsSync()) await resetState();
    return ReleaseState.fromJson(jsonDecode(await file.readAsString()));
  }

  Future<ReleaseCheckResult> getFlutterReleases([String? previousEtag]) async {
    final client = HttpClient();

    try {
      final url = Uri.parse(_releaseEndpoint);
      final request = await client.getUrl(url);

      if (previousEtag != null) request.headers.set(HttpHeaders.ifNoneMatchHeader, previousEtag);

      final response = await request.close();

      if (response.statusCode == HttpStatus.notModified) return const NoUpdate();
      if (response.statusCode != HttpStatus.ok) throw 'Failed to load releases: ${response.statusCode}';

      final body = await response.transform(utf8.decoder).join();
      final json = jsonDecode(body);

      final newEtag = response.headers.value(HttpHeaders.etagHeader);

      if (newEtag == null) throw 'No etag found';
      if (newEtag == previousEtag) throw 'No new release found, etag is the same';

      return Updated(
        ReleaseState(etag: newEtag, lastModified: DateTime.now(), releases: ReleaseState.mapReleases(json)),
      );
    } finally {
      client.close(force: true);
    }
  }

  String getNewReleasesText(List<Release> oldReleases, List<Release> newReleases) {
    final existingReleaseHashes = oldReleases.map((r) => r.hash).toSet();
    final newReleasesFound = newReleases.where((release) => !existingReleaseHashes.contains(release.hash)).toList();
    if (newReleasesFound.isEmpty) throw 'State has been marked as Updated, but no new releases found.';

    final count = newReleasesFound.length;
    final noun = count == 1 ? 'Update' : 'Updates';
    final header = '🎉 *$count New SDK $noun available!*';

    newReleasesFound.sort((a, b) {
      try {
        Version parseReleaseVersion(String s) => Version.parse(s.startsWith('v') ? s.substring(1) : s);
        final versionA = parseReleaseVersion(a.version);
        final versionB = parseReleaseVersion(b.version);
        return versionB.compareTo(versionA);
      } catch (e) {
        TelegramService.notifyAdmin('🚨 Failed to parse version for sorting. Keeping original order. Error: $e');
        return 0;
      }
    });

    final newReleasesLines = newReleasesFound.map((r) => '✅ `${r.channel.name}` • Flutter *${r.version}*').toList();
    return '$header\n\n${newReleasesLines.join('\n')}';
  }
}
