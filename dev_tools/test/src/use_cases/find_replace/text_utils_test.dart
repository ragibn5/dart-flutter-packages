import 'dart:io';

import 'package:dev_tools/src/use_cases/find_replace/replace_text_in_scope.dart';
import 'package:dev_tools/src/use_cases/prompts/confirm_yes_no.dart';
import 'package:dev_tools/src/utils/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockConfirmYesNo extends Mock implements ConfirmYesNo {}

class _FakeLogger implements Logger {
  final List<String> messages = [];

  @override
  void info(String message) => messages.add(message);

  @override
  void warn(String message) => messages.add(message);

  @override
  void error(String message, {StackTrace? stackTrace}) => messages.add(message);
}

void main() {
  late Directory tempDir;

  late _FakeLogger logger;
  late _MockConfirmYesNo confirmYesNo;

  late ReplaceTextInScope sut;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('text_utils_test');
    logger = _FakeLogger();
    confirmYesNo = _MockConfirmYesNo();

    when(() => confirmYesNo(any())).thenAnswer((_) async => true);

    sut = ReplaceTextInScope(
      logger: logger,
      confirmYesNo: confirmYesNo,
    );
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('should replace text across files and return the count', () async {
    final fileA = File('${tempDir.path}/a.dart')
      ..writeAsStringSync('hello world\nhello again\n');
    final fileB = File('${tempDir.path}/b.txt')
      ..writeAsStringSync('nothing here\n');

    final count = await sut(
      srcText: 'hello',
      targetText: 'goodbye',
      start: tempDir.path,
      interactive: false,
    );

    expect(count, 2);
    expect(logger.messages, contains(contains('Replaced 2 occurrence(s).')));
    expect(fileA.readAsStringSync(), 'goodbye world\ngoodbye again\n');
    expect(fileB.readAsStringSync(), 'nothing here\n');
  });

  test('should only skip .dart_tool and build files when excluded', () async {
    File('${tempDir.path}/a.dart').writeAsStringSync('foo foo\n');
    final dartTool = Directory('${tempDir.path}/.dart_tool')..createSync();
    File('${dartTool.path}/cache.dart').writeAsStringSync('foo foo\n');

    final count = await sut(
      srcText: 'foo',
      targetText: 'bar',
      start: tempDir.path,
      interactive: false,
    );

    expect(count, 4);
    expect(File('${dartTool.path}/cache.dart').readAsStringSync(), 'bar bar\n');

    final skipped = await sut(
      srcText: 'bar',
      targetText: 'qux',
      start: tempDir.path,
      interactive: false,
      exclusions: const ['.dart_tool/**', '**/build/**'],
    );

    expect(skipped, 2);
    expect(File('${dartTool.path}/cache.dart').readAsStringSync(), 'bar bar\n');
    expect(File('${tempDir.path}/a.dart').readAsStringSync(), 'qux qux\n');
  });

  test('should return 0 when no occurrences are found', () async {
    File('${tempDir.path}/a.txt').writeAsStringSync('no match here\n');

    final count = await sut(
      srcText: 'missing',
      targetText: 'x',
      start: tempDir.path,
      interactive: false,
    );

    expect(count, 0);
  });

  test(
    'should leave files unchanged and report the count when declined',
    () async {
      when(() => confirmYesNo(any())).thenAnswer((_) async => false);
      final file = File('${tempDir.path}/a.txt')
        ..writeAsStringSync('hello hello\n');

      final count = await sut(
        srcText: 'hello',
        targetText: 'goodbye',
        start: tempDir.path,
      );

      expect(count, 2);
      expect(file.readAsStringSync(), 'hello hello\n');
      expect(logger.messages, contains(contains('Found 2 occurrence(s).')));
      expect(
        logger.messages,
        isNot(contains(contains('Replaced 2 occurrence(s).'))),
      );
    },
  );

  test('should ask for confirmation before replacing when interactive',
      () async {
    File('${tempDir.path}/a.txt').writeAsStringSync('hello\n');

    await sut(
      srcText: 'hello',
      targetText: 'goodbye',
      start: tempDir.path,
    );

    verify(() =>
            confirmYesNo('Replace "hello" with "goodbye" in all the files?'))
        .called(1);
  });

  test('should replace case-insensitively when ignoreCase is true', () async {
    final file = File('${tempDir.path}/a.txt')
      ..writeAsStringSync('Hello HELLO hello\n');

    final count = await sut(
      srcText: 'hello',
      targetText: 'bye',
      start: tempDir.path,
      interactive: false,
      ignoreCase: true,
    );

    expect(count, 3);
    expect(file.readAsStringSync(), 'bye bye bye\n');
  });

  test('should only replace whole words when matchWord is true', () async {
    final file = File('${tempDir.path}/a.txt')
      ..writeAsStringSync('hello hellothere xhello hi-hello\n');

    final count = await sut(
      srcText: 'hello',
      targetText: 'bye',
      start: tempDir.path,
      interactive: false,
      matchWord: true,
    );

    expect(count, 2);
    expect(file.readAsStringSync(), 'bye hellothere xhello hi-bye\n');
  });

  test('should treat srcText as a regular expression when regex is true',
      () async {
    final file = File('${tempDir.path}/a.txt')
      ..writeAsStringSync('Item 12 and item 345\n');

    final count = await sut(
      srcText: r'item \d+',
      targetText: 'value',
      start: tempDir.path,
      interactive: false,
      regex: true,
      ignoreCase: true,
    );

    expect(count, 2);
    expect(file.readAsStringSync(), 'value and value\n');
  });

  test('should skip files matched by exclusion patterns', () async {
    File('${tempDir.path}/a.txt').writeAsStringSync('foo foo\n');
    final skipDir = Directory('${tempDir.path}/generated')..createSync();
    File('${skipDir.path}/b.txt').writeAsStringSync('foo foo\n');
    File('${tempDir.path}/c.g.dart').writeAsStringSync('foo foo\n');

    final count = await sut(
      srcText: 'foo',
      targetText: 'bar',
      start: tempDir.path,
      interactive: false,
      exclusions: const ['generated/**', '*.g.dart'],
    );

    expect(count, 2);
    expect(File('${tempDir.path}/a.txt').readAsStringSync(), 'bar bar\n');
    expect(File('${skipDir.path}/b.txt').readAsStringSync(), 'foo foo\n');
    expect(File('${tempDir.path}/c.g.dart').readAsStringSync(), 'foo foo\n');
  });

  test(
    'should treat a bare or trailing-slash directory pattern as excluding '
    'its subtree',
    () async {
      File('${tempDir.path}/a.txt').writeAsStringSync('foo foo\n');
      final bareDir = Directory('${tempDir.path}/generated')..createSync();
      File('${bareDir.path}/b.txt').writeAsStringSync('foo foo\n');
      final slashDir = Directory('${tempDir.path}/out')..createSync();
      File('${slashDir.path}/c.txt').writeAsStringSync('foo foo\n');

      final count = await sut(
        srcText: 'foo',
        targetText: 'bar',
        start: tempDir.path,
        interactive: false,
        exclusions: const ['generated', 'out/'],
      );

      expect(count, 2);
      expect(File('${tempDir.path}/a.txt').readAsStringSync(), 'bar bar\n');
      expect(File('${bareDir.path}/b.txt').readAsStringSync(), 'foo foo\n');
      expect(File('${slashDir.path}/c.txt').readAsStringSync(), 'foo foo\n');
    },
  );

  test('should not follow directory symlinks unless followLinks is true',
      () async {
    final outside = Directory.systemTemp.createTempSync('text_utils_outside');
    final file = File('${outside.path}/data.txt')
      ..writeAsStringSync('foo foo\n');
    Link('${tempDir.path}/link').createSync(outside.path);

    final skipped = await sut(
      srcText: 'foo',
      targetText: 'bar',
      start: tempDir.path,
      interactive: false,
    );

    expect(skipped, 0);
    expect(file.readAsStringSync(), 'foo foo\n');

    final followed = await sut(
      srcText: 'foo',
      targetText: 'bar',
      start: tempDir.path,
      interactive: false,
      followLinks: true,
    );

    expect(followed, 2);
    expect(file.readAsStringSync(), 'bar bar\n');
    outside.deleteSync(recursive: true);
  });

  test('should throw ArgumentError when srcText is empty', () {
    expect(
      () => sut(srcText: '', targetText: 'b', interactive: false),
      throwsArgumentError,
    );
  });

  test('should throw ArgumentError when targetText is empty', () {
    expect(
      () => sut(srcText: 'a', targetText: '', interactive: false),
      throwsArgumentError,
    );
  });
}
