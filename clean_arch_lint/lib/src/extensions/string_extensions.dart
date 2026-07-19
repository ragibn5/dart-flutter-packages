import 'dart:io';

extension PathExtensions on String {
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

extension PathListExtensions on List<String> {
  bool containsAnyAsPathSegment(String path) {
    return any((name) => path.contains(name.surroundingPathSeparator()));
  }
}
