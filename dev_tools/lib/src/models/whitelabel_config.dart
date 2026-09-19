import 'package:dev_tools/src/models/firebase_flavor_config.dart';
import 'package:dev_tools/src/models/firebase_output_paths.dart';
import 'package:meta/meta.dart';

/// Everything read from a white-label project's
/// `dev_tools_whitelabel_config.yaml`, parsed in a single pass.
@immutable
class WhitelabelConfig {
  /// Project-root-relative glob patterns excluded during copy/clean.
  final List<String> exclude;

  /// The flavors this project supports.
  final List<String> flavors;

  /// Per-flavor Firebase settings, keyed by flavor.
  final Map<String, FirebaseFlavorConfig> firebase;

  /// Templated (`{flavor}`) output paths for `flutterfire configure`.
  final FirebaseOutputPaths firebaseOutputPaths;

  /// Templated (`{flavor}`) splash icon config file path.
  final String splashConfigPath;

  const WhitelabelConfig({
    required this.exclude,
    required this.flavors,
    required this.firebase,
    required this.firebaseOutputPaths,
    required this.splashConfigPath,
  });

  /// Used when no config file exists, or it can't be parsed.
  static const WhitelabelConfig empty = WhitelabelConfig(
    exclude: [],
    flavors: ['dev', 'exp', 'stage', 'prod'],
    firebase: {},
    firebaseOutputPaths: FirebaseOutputPaths.defaults,
    splashConfigPath: 'flutter_native_splash-{flavor}.yaml',
  );
}
