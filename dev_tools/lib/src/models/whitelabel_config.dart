import 'package:dev_tools/src/models/firebase_flavor_config.dart';
import 'package:dev_tools/src/models/firebase_output_paths.dart';
import 'package:dev_tools/src/use_cases/whitelabel/whitelabel_config_exception.dart';
import 'package:meta/meta.dart';

/// Everything read from a white-label project's
/// `dev_tools_whitelabel_config.yaml`.
///
/// [exclude] and [flavors] have safe defaults (no exclusions; no flavors —
/// an absent `flavors:` key is treated the same as `flavors: []`). But
/// [firebaseOutputPaths] and each flavor's entry via [firebaseFor] throw
/// [WhitelabelConfigException] the moment they're read, if the project
/// didn't configure them: there's no fallback that could be correct for an
/// arbitrary project's Firebase settings, so that misconfiguration must be
/// explicit and loud rather than silently guessed.
///
/// The splash icon and launcher icon config file naming isn't part of this
/// model: both `flutter_native_splash` and `flutter_launcher_icons` have
/// their own fixed file-discovery conventions the tools require regardless
/// of what a project might declare, so those guides hardcode the matching
/// pattern instead of reading it from here.
@immutable
class WhitelabelConfig {
  /// Project-root-relative glob patterns excluded during copy/clean.
  final List<String> exclude;

  final List<String>? _flavors;
  final Map<String, FirebaseFlavorConfig> _firebase;
  final FirebaseOutputPaths? _firebaseOutputPaths;

  const WhitelabelConfig({
    required this.exclude,
    required List<String>? flavors,
    required Map<String, FirebaseFlavorConfig> firebase,
    required FirebaseOutputPaths? firebaseOutputPaths,
  })  : _flavors = flavors,
        _firebase = firebase,
        _firebaseOutputPaths = firebaseOutputPaths;

  /// The flavors this project supports.
  ///
  /// An absent `flavors:` key is treated the same as an explicit
  /// `flavors: []` — both mean this project has no flavors.
  List<String> get flavors => _flavors ?? const [];

  /// Templated (`{flavor}`) output paths for `flutterfire configure`.
  ///
  /// Throws [WhitelabelConfigException] when `firebase.output` isn't set.
  FirebaseOutputPaths get firebaseOutputPaths =>
      _firebaseOutputPaths ??
      (throw const WhitelabelConfigException(
        "Missing 'firebase.output' in dev_tools_whitelabel_config.yaml. "
        'Declare ios/android/dart output path templates '
        '(see ReadWhitelabelConfig for the shape).',
      ));

  /// Firebase settings for [flavor].
  ///
  /// Throws [WhitelabelConfigException] when `firebase.<flavor>` isn't set,
  /// or is missing one of `project_id`/`ios_bundle_id`/
  /// `android_package_name`, for this specific [flavor].
  FirebaseFlavorConfig firebaseFor(String flavor) =>
      _firebase[flavor] ??
      (throw WhitelabelConfigException(
        "Missing 'firebase.$flavor' in dev_tools_whitelabel_config.yaml. "
        'Declare project_id, ios_bundle_id, and android_package_name for '
        'this flavor.',
      ));
}
