import 'dart:io';

import 'package:dev_tools/src/utils/logger.dart';

/// Builds a git tag/git-install reference for a package release by
/// substituting `{name}`/`{version}` placeholders into a format template.
class GetTagFormat {
  final ResolveGitTagFormat _resolveGitTagFormat;

  const GetTagFormat(this._resolveGitTagFormat);

  /// Substitutes [name] and [version] into this instance's format template.
  String call({required String name, required String version}) {
    return _resolveGitTagFormat()
        .replaceAll('{name}', name)
        .replaceAll('{version}', version);
  }
}

/// Resolves which git-tag format template to use.
class ResolveGitTagFormat {
  /// The default git-tag naming template (e.g. `foo-1.0.0`): the name of the
  /// git tag a release creates, and the exact form its README's git-install
  /// snippet is expected to reference.
  ///
  /// Projects with their own tagging convention (e.g. `{name}@{version}`, a
  /// `v{version}` suffix, ...) can pass a different template wherever a git
  /// tag format is accepted, instead of this default.
  static const defaultGitTagFormat = '{name}-{version}';

  /// The environment variable CI can set to override [defaultGitTagFormat]
  /// without needing to write Dart code (see [ResolveGitTagFormat]).
  static const gitTagFormatEnvVar = 'DEV_TOOLS_GIT_TAG_FORMAT';

  final Logger _logger;

  const ResolveGitTagFormat({Logger logger = const ConsoleLogger()})
      : _logger = logger;

  /// Resolves the git-tag format: the [gitTagFormatEnvVar] environment
  /// variable when it's set to a valid format, otherwise
  /// [defaultGitTagFormat].
  ///
  /// A malformed override (missing the `{name}` or `{version}` placeholder)
  /// falls back to the default rather than producing a tag that can't
  /// distinguish packages or versions; a warning is logged (see [Logger])
  /// so the misconfiguration isn't silently ignored.
  ///
  /// Params:
  /// - `environment`: process environment to read [gitTagFormatEnvVar]
  ///   from (default: [Platform.environment]). Overridable for testing.
  String call({Map<String, String>? environment}) {
    final envValue = (environment ?? Platform.environment)[gitTagFormatEnvVar];
    if (envValue == null) {
      return defaultGitTagFormat;
    }
    if (_isValid(envValue)) {
      return envValue;
    }

    _logger.warn(
      'Warning: $gitTagFormatEnvVar="$envValue" is missing a {name} or '
      '{version} placeholder; falling back to the default git tag format '
      '"$defaultGitTagFormat".',
    );
    return defaultGitTagFormat;
  }

  /// Whether [format] references both the `{name}` and `{version}`
  /// placeholders, so a substituted tag can still distinguish packages and
  /// versions from one another.
  static bool _isValid(String format) =>
      format.contains('{name}') && format.contains('{version}');
}
