import 'dart:convert';
import 'dart:io';

import 'package:flutter_releases/models/release.dart';
import 'package:flutter_releases/models/release_check_result.dart';
import 'package:flutter_releases/models/release_state.dart';
import 'package:flutter_releases/services/telegram_service.dart';
import 'package:pub_semver/pub_semver.dart';

class LocalStateService {
  const LocalStateService();

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
      if (response.statusCode != HttpStatus.ok) throw HttpException('Failed to load releases: ${response.statusCode}');

      final body = await response.transform(utf8.decoder).join();
      final json = jsonDecode(body);

      final newEtag = response.headers.value(HttpHeaders.etagHeader);

      if (newEtag == null) throw Exception('No etag found');
      if (newEtag == previousEtag) throw Exception('No new release found, etag is the same');

      return Updated(
        ReleaseState(etag: newEtag, lastModified: DateTime.now(), releases: ReleaseState.mapReleases(json)),
      );
    } finally {
      client.close(force: true);
    }
  }

  bool areReleasesIdentical(List<Release> r1, List<Release> r2) => r1.toSet().difference(r2.toSet()).isEmpty;

  String getNewReleasesText(List<Release> oldReleases, List<Release> newReleases) {
    final existingReleaseHashes = oldReleases.map((r) => r.hash).toSet();
    final newReleasesFound = newReleases.where((release) => !existingReleaseHashes.contains(release.hash)).toList();
    if (newReleasesFound.isEmpty) throw Exception('State has been marked as Updated, but no new releases found.');

    final count = newReleasesFound.length;
    final noun = count == 1 ? 'Update' : 'Updates';
    final header = '🎉 *$count New SDK $noun available\\!*';

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

    final newReleaseLines = newReleasesFound.map((r) {
      final escapedVersion = TelegramService.getEscapedText(r.version);
      return '✅ `${r.channel.name}` • Flutter *$escapedVersion*';
    }).toList();

    return '$header\n\n${newReleaseLines.join('\n')}';
  }
}
