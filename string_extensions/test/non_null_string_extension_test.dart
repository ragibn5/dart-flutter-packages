// ignore_for_file: use_raw_strings, lines_longer_than_80_chars
import 'package:string_extensions/string_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('isEmptyOrBlank', () {
    test(
      'empty string',
      () => expect(''.isEmptyOrBlank, true),
    );
    test(
      'blank string',
      () => expect('   '.isEmptyOrBlank, true),
    );
    test(
      'non-empty string',
      () => expect('Hello'.isEmptyOrBlank, false),
    );
    test(
      'string with surrounding spaces',
      () => expect('  Hello  '.isEmptyOrBlank, false),
    );
  });

  group('isMultiline', () {
    test('single line', () => expect('Hello'.isMultiline, false));
    test(
      'multi-line with \\n',
      () => expect('Hello\nWorld'.isMultiline, true),
    );
    test(
      'multi-line with \\r\\n',
      () => expect('Hello\r\nWorld'.isMultiline, true),
    );
  });

  group('lineCount', () {
    test('single line', () => expect('Hello'.lineCount, 1));
    test('two lines', () => expect('Hello\nWorld'.lineCount, 2));
    test('three lines', () => expect('Hello\nWorld\nDart'.lineCount, 3));
  });

  group('capitalizeWord', () {
    test('single word', () => expect('hello'.capitalizeWord, 'Hello'));
    test(
      'multiple words',
      () => expect('hello world'.capitalizeWord, 'Hello world'),
    );
    test(
      'already capitalized',
      () => expect('HELLO'.capitalizeWord, 'HELLO'),
    );
  });

  group('capitalizeSentence', () {
    test(
      'simple sentence',
      () => expect('hello world'.capitalizeSentence, 'Hello world'),
    );
    test(
      'sentence with punctuation',
      () => expect(
          'this is a sentence.'.capitalizeSentence, 'This is a sentence.'),
    );
  });

  group('capitalizeWords', () {
    test('single word', () => expect('hello'.capitalizeWords, 'Hello'));
    test(
      'two words',
      () => expect('hello world'.capitalizeWords, 'Hello World'),
    );
    test(
      'full sentence',
      () => expect('this is a sentence'.capitalizeWords, 'This Is A Sentence'),
    );
  });

  group('containsIgnoreCase', () {
    test('contains substring (case insensitive)', () {
      expect('Hello World'.containsIgnoreCase('hello'), true);
      expect('Hello World'.containsIgnoreCase('WORLD'), true);
      expect('Hello World'.containsIgnoreCase('dart'), false);
    });
  });

  group('compareToIgnoreCase', () {
    test(
      'equal strings',
      () => expect('apple'.compareToIgnoreCase('APPLE'), 0),
    );
    test(
      'less than',
      () => expect('apple'.compareToIgnoreCase('banana'), -1),
    );
    test(
      'greater than',
      () => expect('zebra'.compareToIgnoreCase('Apple'), 1),
    );
    test(
      'same word different case',
      () => expect('Hello'.compareToIgnoreCase('hello'), 0),
    );
  });

  group('getWords', () {
    test(
      'normal sentence',
      () => expect('Hello World'.getWords(), ['Hello', 'World']),
    );
    test(
      'multiple spaces',
      () => expect('This is a  test'.getWords(), ['This', 'is', 'a', 'test']),
    );
    test('empty string', () => expect(''.getWords(), List<String>.empty()));
  });

  group('getFirstLine', () {
    test('empty string', () => expect(''.getFirstLine(), ''));
    test(
      'single line',
      () => expect('Hello World'.getFirstLine(), 'Hello World'),
    );
    test(
      'multi-line string',
      () => expect('Hello\nWorld'.getFirstLine(), 'Hello'),
    );
  });

  group('getFirstNLine', () {
    test(
      'throws for lineCount 0',
      () => expect(
        () => 'Hello\nWorld'.getFirstNLine(lineCount: 0),
        throwsArgumentError,
      ),
    );
    test('single line request', () {
      expect('Hello'.getFirstNLine(lineCount: 1), 'Hello');
      expect('Hello\n'.getFirstNLine(lineCount: 1), 'Hello');
      expect('Hello\nWorld'.getFirstNLine(lineCount: 1), 'Hello');
    });
    test('multiple lines request', () {
      expect(
        'Line1\nLine2\nLine3\nLine4'.getFirstNLine(lineCount: 2),
        'Line1\nLine2',
      );
      expect(
        'Hello\nWorld\nx\ny\nz'.getFirstNLine(lineCount: 5),
        'Hello\nWorld\nx\ny\nz',
      );
    });
    test('request more lines than available', () {
      expect('Hello World'.getFirstNLine(lineCount: 3), 'Hello World');
      expect('Hello\nWorld'.getFirstNLine(lineCount: 4), 'Hello\nWorld');
    });
  });

  group('trimLines', () {
    test(
      'multi-line string',
      () => expect(
        '  hello  \n  world  \n  dart  '.trimLines(),
        'hello\nworld\ndart',
      ),
    );
    test('empty string', () => expect(''.trimLines(), ''));
    test(
      'single line',
      () => expect('  single line  '.trimLines(), 'single line'),
    );
    test(
      'preserves empty lines',
      () => expect(
        '  line1  \n\n  line2  \n  \n  line3  '.trimLines(),
        'line1\n\nline2\n\nline3',
      ),
    );
    test('whitespace lines', () => expect('  \n  \n  '.trimLines(), '\n\n'));
    test(
      'with prefix',
      () => expect(
        '  line1  \n  line2  '.trimLines(prefix: 'PREFIX'),
        'PREFIXline1\nline2',
      ),
    );
    test(
      'with suffix',
      () => expect(
        '  line1  \n  line2  '.trimLines(suffix: 'SUFFIX'),
        'line1\nline2SUFFIX',
      ),
    );
    test(
      'with prefix and suffix',
      () => expect(
        '  line1  \n  line2  '.trimLines(prefix: 'START', suffix: 'END'),
        'STARTline1\nline2END',
      ),
    );
    test(
      'tabs and whitespace',
      () => expect(
        '\tline1\t\n\t  line2  \t\n \t line3 \t '.trimLines(),
        'line1\nline2\nline3',
      ),
    );
  });
}
