import 'package:extended_string/src/constants.dart';

extension NonNullStringExtension on String {
  /// Determines whether this string is empty (length = 0),
  /// or blank (length > 0, but all characters are whitespace characters).
  ///
  /// Example:
  /// ```dart
  /// ''.isEmptyOrBlank; // true
  /// '   '.isEmptyOrBlank; // true
  /// 'Hello'.isEmptyOrBlank; // false
  /// '  Hello  '.isEmptyOrBlank; // false
  /// ```
  bool get isEmptyOrBlank {
    return trim().isEmpty;
  }

  /// Determines whether this string is multiline,
  /// i.e. contains at least one platform specific line separator.
  ///
  /// On Windows, this is '\r\n', on all other platforms, it is '\n'.
  ///
  /// Example:
  /// ```dart
  /// 'Hello'.isMultiline; // false
  /// 'Hello\nWorld'.isMultiline; // true
  /// 'Hello\r\nWorld'.isMultiline; // true (on Windows)
  /// ```
  bool get isMultiline {
    if (isEmpty) {
      return false;
    }
    return contains(Constants.lineSeparator);
  }

  /// Determines the line count,
  /// i.e. the number of platform specific line separator + 1.
  ///
  /// On Windows, this is '\r\n', on all other platforms, it is '\n'.
  ///
  /// Example:
  /// ```dart
  /// 'Hello'.lineCount; // 1 (no line separators)
  /// 'Hello\nWorld'.lineCount; // 2 (one line separator)
  /// 'Hello\nWorld\nDart'.lineCount; // 3 (two line separators)
  /// ```
  int get lineCount {
    if (isEmpty) {
      return 0;
    }
    return RegExp(Constants.lineSeparator).allMatches(this).length + 1;
  }

  /// Capitalize the first character of a word or sentence.
  ///
  /// Note, if this is applied to a sentence,
  /// it will only capitalize the first character of the first word.
  ///
  /// Example:
  /// ```dart
  /// 'hello'.capitalizeWord; // 'Hello'
  /// 'hello world'.capitalizeWord; // 'Hello world'
  /// 'HELLO'.capitalizeWord; // 'HELLO' (already capitalized)
  /// ```
  String get capitalizeWord {
    if (isEmpty) return this;
    return replaceRange(0, 1, this[0].toUpperCase());
  }

  /// Capitalize the first character of the sentence.
  ///
  /// Note, internally it uses [capitalizeWord],
  /// it is provided just to remove the confusion
  /// that we need something for a sentence as well.
  ///
  /// Example:
  /// ```dart
  /// 'hello world'.capitalizeSentence; // 'Hello world'
  /// 'this is a sentence.'.capitalizeSentence; // 'This is a sentence.'
  /// ```
  String get capitalizeSentence {
    return capitalizeWord;
  }

  /// Capitalize the first characters of all the words of the given sentence.
  /// If applied to a word, will capitalize the first character of that word.
  ///
  /// Example:
  /// ```dart
  /// 'hello'.capitalizeWords; // 'Hello'
  /// 'hello world'.capitalizeWords; // 'Hello World'
  /// 'this is a sentence'.capitalizeWords; // 'This Is A Sentence'
  /// ```
  String get capitalizeWords {
    final splits = getWords();
    final buffer = StringBuffer();
    for (var i = 0; i < splits.length; ++i) {
      if (!splits[i].isEmptyOrBlank) {
        buffer.write(splits[i].capitalizeWord);
      }
      if (i < (splits.length - 1)) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  /// Checks whether this string contains the given string, case insensitively.
  ///
  /// Example:
  /// ```dart
  /// 'Hello World'.containsIgnoreCase('hello'); // true
  /// 'Hello World'.containsIgnoreCase('WORLD'); // true
  /// 'Hello World'.containsIgnoreCase('dart'); // false
  /// ```
  bool containsIgnoreCase(String another) {
    if (another.isEmpty) {
      return true;
    }
    return toLowerCase().contains(another.toLowerCase());
  }

  /// Compares two strings alphabetically, ignoring case differences.
  ///
  /// Returns:
  ///   * A negative value if this string comes before the other string
  ///   * Zero if the strings are equal (ignoring case)
  ///   * A positive value if this string comes after the other string
  ///
  /// Example:
  /// ```dart
  /// 'apple'.compareToIgnoreCase('APPLE'); // 0 (equal)
  /// 'apple'.compareToIgnoreCase('banana'); // negative (apple comes before banana)
  /// 'zebra'.compareToIgnoreCase('Apple'); // positive (zebra comes after apple)
  /// 'Hello'.compareToIgnoreCase('hello'); // 0 (case is ignored)
  /// ```
  int compareToIgnoreCase(String another) {
    return toLowerCase().compareTo(another.toLowerCase());
  }

  /// Splits the string into words using whitespace regex as a delimiter.
  ///
  /// Example:
  /// ```dart
  /// 'Hello World'.getWords(); // ['Hello', 'World']
  /// 'This is a  test'.getWords(); // ['This', 'is', 'a', 'test']
  /// ''.getWords(); // []
  /// ```
  List<String> getWords() {
    if (isEmpty) {
      return [];
    }

    return trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
  }

  /// Returns the first line of a multi-line string.
  /// If the string is single-line, returns the entire string.
  ///
  /// Example:
  /// ```dart
  /// 'Hello\nWorld'.getFirstLine(); // 'Hello'
  /// 'Hello World'.getFirstLine(); // 'Hello World'
  /// ```
  String getFirstLine() {
    return getFirstNLine(lineCount: 1);
  }

  /// Returns the first N lines of a multi-line string.
  /// If the string has fewer than N lines, returns the entire string.
  ///
  /// Example:
  /// ```dart
  /// 'Line1\nLine2\nLine3\nLine4'.getFirstNLine(lineCount: 2); // 'Line1\nLine2'
  /// 'Hello World'.getFirstNLine(lineCount: 3); // 'Hello World'
  /// ```
  ///
  /// Throws an [ArgumentError] if lineCount is less than or equal to 0.
  String getFirstNLine({required int lineCount}) {
    if (lineCount <= 0) {
      throw ArgumentError('Line count must be > 0');
    }

    if (isEmpty) {
      return '';
    }

    var foundLines = 0;
    var searchPosition = 0;
    var lastFoundPosition = -1;
    final separator = Constants.lineSeparator;

    while (foundLines < lineCount) {
      lastFoundPosition = indexOf(separator, searchPosition);
      if (lastFoundPosition == -1) {
        return this;
      }

      foundLines++;
      if (foundLines == lineCount) {
        return substring(0, lastFoundPosition);
      }

      searchPosition = lastFoundPosition + separator.length;
    }

    // Return the whole string if we didn't find enough line separators
    return this;
  }

  /// Returns a string that is a result of trimming all the
  /// lines separately, and joining them back with platform
  /// specific newline.
  ///
  /// Example:
  /// ```dart
  /// '''
  /// Hello
  ///   World
  /// Hello
  ///     Me
  /// '''.trimLines()
  /// ```
  ///
  /// This gives the following output:
  /// ```dart
  /// Hello
  /// World
  /// Hello
  /// Me
  /// ```
  String trimLines({String prefix = '', String suffix = ''}) {
    final trimResult = split(Constants.lineSeparator)
        .map((e) => e.trim())
        .toList()
        .join(Constants.lineSeparator);

    return '$prefix$trimResult$suffix';
  }
}
