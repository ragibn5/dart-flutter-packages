// ignore_for_file: avoid_init_to_null
// ignore_for_file: prefer_final_locals

import 'package:extended_string/extended_string.dart';

void main() {
  // Demonstrate NonNullStringExtension
  demonstrateNonNullStringExtensions();

  // Demonstrate NullableStringExtension
  demonstrateNullableStringExtensions();
}

void demonstrateNonNullStringExtensions() {
  print('Hello'.getFirstNLine(lineCount: 1));

  print('\n\n=== NonNullStringExtension Examples ===\n');

  // isEmptyOrBlank
  print('--- isEmptyOrBlank ---');
  print("''.isEmptyOrBlank: ${''.isEmptyOrBlank}");
  print("'   '.isEmptyOrBlank: ${'   '.isEmptyOrBlank}");
  print("'Hello'.isEmptyOrBlank: ${'Hello'.isEmptyOrBlank}");

  // isMultiline
  print('\n--- isMultiline ---');
  print("'Hello'.isMultiline: ${'Hello'.isMultiline}");
  print("'Hello\\nWorld'.isMultiline: ${'Hello\nWorld'.isMultiline}");

  // lineCount
  print('\n--- lineCount ---');
  print("'Hello'.lineCount: ${'Hello'.lineCount}");
  print("'Hello\\nWorld'.lineCount: ${'Hello\nWorld'.lineCount}");
  print(
    "'Line1\\nLine2\\nLine3'.lineCount: ${'Line1\nLine2\nLine3'.lineCount}",
  );

  // capitalizeWord
  print('\n--- capitalizeWord ---');
  print("'hello'.capitalizeWord: ${'hello'.capitalizeWord}");

  // capitalizeSentence
  print('\n--- capitalizeSentence ---');
  print(
    "'hello world'.capitalizeSentence: ${'hello world'.capitalizeSentence}",
  );

  // capitalizeWords
  print('\n--- capitalizeWords ---');
  print("'hello world'.capitalizeWords: ${'hello world'.capitalizeWords}");
  print(
    "'this is a test'.capitalizeWords: ${'this is a test'.capitalizeWords}",
  );

  // containsIgnoreCase
  print('\n--- containsIgnoreCase ---');
  print(
    "'Hello World'.containsIgnoreCase('hello'): "
    "${'Hello World'.containsIgnoreCase('hello')}",
  );
  print(
    "'Hello World'.containsIgnoreCase('WORLD'): "
    "${'Hello World'.containsIgnoreCase('WORLD')}",
  );
  print(
    "'Hello World'.containsIgnoreCase('dart'): "
    "${'Hello World'.containsIgnoreCase('dart')}",
  );

  // compareToIgnoreCase
  print('\n--- compareToIgnoreCase ---');
  print(
    "'apple'.compareToIgnoreCase('APPLE'): "
    "${'apple'.compareToIgnoreCase('APPLE')}",
  );
  print(
    "'apple'.compareToIgnoreCase('banana'): "
    "${'apple'.compareToIgnoreCase('banana')}",
  );
  print(
    "'zebra'.compareToIgnoreCase('Apple'): "
    "${'zebra'.compareToIgnoreCase('Apple')}",
  );

  // getWords
  print('\n--- getWords ---');
  print("'Hello World'.getWords(): ${'Hello World'.getWords()}");
  print("'This is a  test'.getWords(): ${'This is a  test'.getWords()}");
  print("''.getWords(): ${''.getWords()}");

  // getFirstLine
  print('\n--- getFirstLine ---');
  print("'Hello\\nWorld'.getFirstLine(): ${'Hello\nWorld'.getFirstLine()}");
  print("'Single line'.getFirstLine(): ${'Single line'.getFirstLine()}");

  // getFirstNLine
  print('\n--- getFirstNLine ---');
  const multilineText = 'Line1\nLine2\nLine3\nLine4\nLine5';
  print(
    'multilineText.getFirstNLine(lineCount: 2): '
    '${multilineText.getFirstNLine(lineCount: 2)}',
  );
  print(
    "'Hello'.getFirstNLine(lineCount: 3): "
    "${'Hello'.getFirstNLine(lineCount: 3)}",
  );
}

void demonstrateNullableStringExtensions() {
  print('\n\n=== NullableStringExtension Examples ===\n');

  // isNullOrEmptyOrBlank
  print('--- isNullOrEmptyOrBlank ---');
  String? nullString = null;
  String? emptyString = '';
  String? blankString = '   ';
  String? validString = 'Hello';

  print('nullString.isNullOrEmptyOrBlank: '
      '${nullString.isNullOrEmptyOrBlank}');
  print(
    'emptyString.isNullOrEmptyOrBlank: '
    '${emptyString.isNullOrEmptyOrBlank}',
  );
  print(
    'blankString.isNullOrEmptyOrBlank: '
    '${blankString.isNullOrEmptyOrBlank}',
  );
  print(
    'validString.isNullOrEmptyOrBlank: '
    '${validString.isNullOrEmptyOrBlank}',
  );

  // nullOnEmptyOrBlank
  print('\n--- nullOnEmptyOrBlank ---');
  print('nullString.nullOnEmptyOrBlank: ${nullString.nullOnEmptyOrBlank}');
  print('emptyString.nullOnEmptyOrBlank: ${emptyString.nullOnEmptyOrBlank}');
  print('blankString.nullOnEmptyOrBlank: ${blankString.nullOnEmptyOrBlank}');
  print('validString.nullOnEmptyOrBlank: ${validString.nullOnEmptyOrBlank}');
}
