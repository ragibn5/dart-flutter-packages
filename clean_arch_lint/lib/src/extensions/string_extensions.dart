import 'dart:io';

extension PathStringExtensions on String {
  String surroundingPathSeparator({
    bool trimWhitespaces = true,
    bool trimExistingPathSeparator = true,
  }) {
    final pathSeparator = Platform.pathSeparator;

    var modifiableSubject = this;
    if (trimWhitespaces) {
      modifiableSubject = modifiableSubject.trim();
    }
    if (trimExistingPathSeparator) {
      modifiableSubject = modifiableSubject.replaceAll(
        Platform.pathSeparator,
        '',
      );
    }

    return '$pathSeparator$modifiableSubject$pathSeparator';
  }
}
