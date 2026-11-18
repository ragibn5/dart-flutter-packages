import 'dart:io';

import 'package:content_io_android/src/exceptions/content_read_exception.dart';
import 'package:content_io_android/src/io/reader/file_content_reader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late String path;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('file_byte_source');
    path = '${directory.path}/item.bin';
    await File(path).writeAsBytes([0, 1, 2, 3, 4, 5]);
  });

  tearDown(() => directory.delete(recursive: true));

  test('openShouldReturnReaderWithIdAndFileLengthIfFileExists', () async {
    final reader = await FileContentReader.open(id: 'local-1', path: path);
    addTearDown(reader.close);

    expect(reader.id, 'local-1');
    expect(reader.length, 6);
  });

  test('openShouldThrowFileSystemExceptionIfFileIsMissing', () {
    expect(
      FileContentReader.open(id: 'local-1', path: '${directory.path}/missing'),
      throwsA(isA<FileSystemException>()),
    );
  });

  test('isSeekableShouldBeTrue', () async {
    final reader = await FileContentReader.open(id: 'local-1', path: path);
    addTearDown(reader.close);

    expect(reader.isSeekable, isTrue);
  });

  group('read', () {
    late FileContentReader reader;

    setUp(() async {
      reader = await FileContentReader.open(id: 'local-1', path: path);
    });

    tearDown(() => reader.close());

    test('readShouldContinueFromPreviousReadIfPositionIsNotGiven', () async {
      await reader.read(2);

      expect(await reader.read(2), [2, 3]);
    });

    test('readShouldReadFromPositionIfPositionIsGiven', () async {
      expect(await reader.read(2, position: 3), [3, 4]);
    });

    test('readShouldReturnFewerBytesIfFewerAreLeft', () async {
      expect(await reader.read(4, position: 4), [4, 5]);
    });

    test('readShouldThrowRangeErrorIfPositionIsNegative', () {
      expect(reader.read(2, position: -1), throwsRangeError);
    });

    test('readShouldThrowReadExceptionIfFileFails', () async {
      await reader.close();

      expect(reader.read(2), throwsA(isA<ReadException>()));
    });
  });

  group('readAll', () {
    late FileContentReader reader;

    setUp(() async {
      reader = await FileContentReader.open(id: 'local-1', path: path);
    });

    tearDown(() => reader.close());

    test(
      'readAllShouldReadToEndFromCurrentPositionIfPositionIsNotGiven',
      () async {
        await reader.read(2);

        expect(await reader.readAll(), [2, 3, 4, 5]);
      },
    );

    test('readAllShouldReadToEndFromPositionIfPositionIsGiven', () async {
      expect(await reader.readAll(position: 4), [4, 5]);
    });

    test('readAllShouldThrowRangeErrorIfPositionIsNegative', () {
      expect(reader.readAll(position: -1), throwsRangeError);
    });

    test('readAllShouldThrowReadExceptionIfFileFails', () async {
      await reader.close();

      expect(reader.readAll(), throwsA(isA<ReadException>()));
    });
  });

  test('closeShouldNotThrowIfAlreadyClosed', () async {
    final reader = await FileContentReader.open(id: 'local-1', path: path);
    await reader.close();

    await expectLater(reader.close(), completes);
  });
}
