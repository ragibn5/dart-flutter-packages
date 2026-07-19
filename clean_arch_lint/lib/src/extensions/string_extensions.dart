extension PathExtensions on String {
  /// Wraps this string with `/` on both sides to match as a full path segment.
  ///
  /// e.g. `'domain'` → `'/domain/'`
  String surroundingPathSeparator({
    bool trimWhitespaces = true,
    bool trimExistingPathSeparators = true,
  }) {
    var modifiableSubject = this;
    if (trimWhitespaces) {
      modifiableSubject = modifiableSubject.trim();
    }
    if (trimExistingPathSeparators) {
      modifiableSubject = modifiableSubject
          .replaceAll('/', '')
          .replaceAll(r'\', '');
    }

    return '/$modifiableSubject/';
  }
}

extension PathListExtensions on List<String> {
  bool containsAnyAsPathSegment(String path) {
    return any((name) => path.contains(name.surroundingPathSeparator()));
  }
}
