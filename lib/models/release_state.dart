import 'package:deep_pick/deep_pick.dart';
import 'package:flutter_notify/enums/channel.dart';
import 'package:flutter_notify/models/release.dart';

class ReleaseState {
  const ReleaseState({required this.etag, required this.lastModified, required this.releases});

  final String etag;
  final DateTime lastModified;
  final List<Release> releases;

  factory ReleaseState.fromJson(dynamic json) {
    final data = pick(json);
    return ReleaseState(
      etag: data('etag').asStringOrThrow(),
      lastModified: data('last_modified').asDateTimeOrThrow(),
      releases: mapReleases(json),
    );
  }

  Map<String, dynamic> toJson() => {
    'etag': etag,
    'last_modified': lastModified.toIso8601String(),
    'releases': releases.map((release) => release.toJson()).toList(),
  };

  static List<Release> mapReleases(dynamic releases) => pick(releases, 'releases').asListOrThrow((releaseData) {
    return Release(
      hash: releaseData('hash').asStringOrThrow(),
      channel: Channel.values.byName(releaseData('channel').asStringOrThrow()),
      version: releaseData('version').asStringOrThrow(),
      releaseDate: releaseData('release_date').asDateTimeOrThrow(),
      archivePath: releaseData('archive').asStringOrThrow(),
      sha256: releaseData('sha256').asStringOrThrow(),
    );
  });

  @override
  String toString() => 'ReleaseState(etag: $etag, lastModified: $lastModified, releases: $releases)';
}
