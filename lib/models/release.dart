import 'package:flutter_releases/enums/channel.dart';

class Release {
  const Release({
    required this.hash,
    required this.channel,
    required this.version,
    required this.releaseDate,
    required this.archivePath,
    required this.sha256,
  });

  final String hash;
  final Channel channel;
  final String version;
  final DateTime releaseDate;
  final String archivePath;
  final String sha256;

  Map<String, String> toJson() => {
    'hash': hash,
    'channel': channel.name,
    'version': version,
    'release_date': releaseDate.toIso8601String(),
    'archive': archivePath,
    'sha256': sha256,
  };

  @override
  String toString() =>
      'Release(hash: $hash, channel: $channel, version: $version, releaseDate: $releaseDate, archivePath: $archivePath, sha256: $sha256)';

  @override
  int get hashCode => Object.hash(hash, channel);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Release && other.hash == hash && other.channel == channel;
  }
}
