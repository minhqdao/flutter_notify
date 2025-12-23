import 'dart:convert';
import 'dart:io';

import 'package:flutter_notify/enums/channel.dart';
import 'package:flutter_notify/models/release.dart';
import 'package:flutter_notify/models/release_check_result.dart';
import 'package:flutter_notify/models/release_state.dart';
import 'package:flutter_notify/services/telegram_service.dart';
import 'package:pub_semver/pub_semver.dart';

class ReleaseStateService {
  const ReleaseStateService._();

  static const _stateFile = '.state/releases.json';
  static const _releaseEndpoint = 'https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json';

  static Future<void> resetState() async {
    switch (await getAllFlutterReleases()) {
      case Updated(state: final state):
        await writeState(state);
      case NoUpdate():
    }
  }

  static Future<void> writeState(ReleaseState releaseState) async {
    await File(_stateFile).parent.create(recursive: true);
    final tmpFile = File('$_stateFile.tmp');
    await tmpFile.writeAsString(const JsonEncoder.withIndent('  ').convert(releaseState.toJson()));
    await tmpFile.rename(_stateFile);
  }

  static Future<ReleaseState> getLocalReleaseState() async {
    final file = File(_stateFile);
    if (!file.existsSync()) await resetState();
    return ReleaseState.fromJson(jsonDecode(await file.readAsString()));
  }

  static Future<ReleaseCheckResult> getAllFlutterReleases([String? previousEtag]) async {
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

  static List<Release> getSortedReleasesDiff(List<Release> oldReleases, List<Release> newReleases) {
    final existingReleaseHashes = oldReleases.map((r) => r.hash).toSet();
    final newReleasesFound = newReleases.where((release) => !existingReleaseHashes.contains(release.hash)).toList();
    if (newReleasesFound.isEmpty) throw 'State has been marked as Updated, but no new releases found.';

    return getReleasesSortedByDescendingVersion(newReleasesFound);
  }

  static List<Release> getReleasesSortedByDescendingVersion(List<Release> releases) {
    final List<({Release release, Version? version})> mapped = releases.map((r) {
      try {
        final cleanVersion = r.version.startsWith('v') ? r.version.substring(1) : r.version;
        return (release: r, version: Version.parse(cleanVersion));
      } catch (e) {
        TelegramService.notifyAdmin('🚨 Failed to parse version for sorting. Error: $e');
        return (release: r, version: null);
      }
    }).toList();

    mapped.sort((a, b) {
      if (a.version == null) return 1;
      if (b.version == null) return -1;
      return b.version!.compareTo(a.version!);
    });

    return mapped.map((m) => m.release).toList();
  }

  static List<Release> getLatestRelease(List<Release> releases, Channel channel, int amount) =>
      getReleasesSortedByDescendingVersion(releases.where((r) => r.channel == channel).toList()).take(amount).toList();

  static String getNewReleasesText(List<Release> releases) {
    final count = releases.length;
    final noun = count == 1 ? 'Update' : 'Updates';
    final header = '🎉 *$count New SDK $noun available!*';

    final newReleasesLines = releases.map((r) => '✅ `${r.channel.name}` • Flutter *${r.version}*').toList();
    return '$header\n\n${newReleasesLines.join('\n')}';
  }

  static String getFormattedDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }
}
