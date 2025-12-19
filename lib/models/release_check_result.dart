import 'package:flutter_releases/models/release_state.dart';

sealed class ReleaseCheckResult {
  const ReleaseCheckResult();
}

class NoUpdate extends ReleaseCheckResult {
  const NoUpdate();
}

class Updated extends ReleaseCheckResult {
  const Updated(this.state);

  final ReleaseState state;
}
