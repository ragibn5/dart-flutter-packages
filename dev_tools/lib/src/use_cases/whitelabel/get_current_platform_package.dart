import 'dart:io';

/// Reads the current Android application ID from a project's Gradle build
/// file.
///
/// The template assumes the Android package name and iOS bundle ID are the
/// same, and this is used for both.
class GetCurrentPlatformPackage {
  static final RegExp _applicationIdPattern = RegExp(
    r'''^\s*applicationId\s*=\s*["']([^"']+)["']''',
    multiLine: true,
  );

  const GetCurrentPlatformPackage();

  /// Reads `applicationId` from `android/app/build.gradle.kts` in
  /// [projectPath].
  ///
  /// Returns: the application ID, or an empty string when it can't be
  /// determined.
  Future<String> call(String projectPath) async {
    final file = File('$projectPath/android/app/build.gradle.kts');
    if (!file.existsSync()) return '';

    final match = _applicationIdPattern.firstMatch(await file.readAsString());
    return match?.group(1) ?? '';
  }
}
