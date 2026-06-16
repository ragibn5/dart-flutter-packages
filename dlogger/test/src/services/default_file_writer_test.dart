// ignore_for_file: cascade_invocations
// ignore_for_file: avoid_redundant_argument_values

import 'dart:convert';
import 'dart:io';

import 'package:dlogger/src/services/default_file_writer.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockFile extends Mock implements File {}

class _MockDirectory extends Mock implements Directory {}

class _FakeFile extends Fake implements File {}

class _FakeFileMode extends Fake implements FileMode {}

class _FakeEncoding extends Fake implements Encoding {}

void main() {
  final lineSeparator = Platform.isWindows ? '\r\n' : '\n';

  late _MockFile mockFile;
  late _MockDirectory mockDirectory;

  late DefaultFileWriter sut;

  setUpAll(() {
    registerFallbackValue(_FakeFile());
    registerFallbackValue(_FakeFileMode());
    registerFallbackValue(_FakeEncoding());
  });

  setUp(() {
    mockFile = _MockFile();
    mockDirectory = _MockDirectory();

    sut = DefaultFileWriter(lineSeparator);
  });

  test('Returns Result.exception on any exception', () {
    when(mockFile.existsSync).thenThrow(Exception('File does not exist'));

    final result = sut.writeSync(mockFile, 'content');

    result.fold(
      onSuccess: (_) => fail('Expected exception, got success'),
      onException: (e, st) => null,
    );
  });

  test('Creates parent directory if it does not exist', () {
    when(() => mockFile.parent).thenReturn(mockDirectory);
    when(() => mockDirectory.existsSync()).thenReturn(false);

    sut.writeSync(mockFile, 'content');

    verify(() => mockDirectory.createSync(recursive: true)).called(1);
  });

  test('Does not create parent directory if it already exist', () {
    when(() => mockFile.parent).thenReturn(mockDirectory);
    when(() => mockDirectory.existsSync()).thenReturn(true);

    sut.writeSync(mockFile, 'content');

    verifyNever(() => mockDirectory.createSync(recursive: true));
  });

  test('Maps exact input params to file.writeAsStringSync', () {
    const content = 'content';
    const mode = FileMode.append;
    const encoding = utf8;
    const flush = true;

    when(() => mockFile.parent).thenReturn(mockDirectory);
    when(() => mockDirectory.existsSync()).thenReturn(false);
    when(() => mockDirectory.createSync(recursive: true)).thenReturn(null);

    sut.writeSync(mockFile, content, mode: mode, flush: flush);

    verify(
      () => mockFile.writeAsStringSync(
        '$content$lineSeparator',
        mode: mode,
        encoding: encoding,
        flush: flush,
      ),
    ).called(1);
  });

  test('Valid case returns Result.success', () {
    const content = 'content';
    const mode = FileMode.append;
    const encoding = utf8;
    const flush = true;

    when(() => mockFile.parent).thenReturn(mockDirectory);
    when(() => mockDirectory.existsSync()).thenReturn(false);
    when(() => mockDirectory.createSync(recursive: true)).thenReturn(null);

    final result = sut.writeSync(
      mockFile,
      content,
      mode: mode,
      encoding: encoding,
      flush: flush,
    );

    expect(result.isSuccess, true);
    expect(result.isException, false);
  });
}
