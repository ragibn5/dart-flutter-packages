import 'dart:io';

import 'package:content_io_android/src/exceptions/content_read_exception.dart';
import 'package:content_io_android/src/io/source/file_byte_source.dart';
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

  test('openShouldReturnSourceWithIdAndFileLengthIfFileExists', () async {
    final source = await FileByteSource.open(id: 'local-1', path: path);
    addTearDown(source.close);

    expect(source.id, 'local-1');
    expect(source.length, 6);
  });

  test('openShouldThrowFileSystemExceptionIfFileIsMissing', () {
    expect(
      FileByteSource.open(id: 'local-1', path: '${directory.path}/missing'),
      throwsA(isA<FileSystemException>()),
    );
  });

  test('isSeekableShouldBeTrue', () async {
    final source = await FileByteSource.open(id: 'local-1', path: path);
    addTearDown(source.close);

    expect(source.isSeekable, isTrue);
  });

  group('read', () {
    late FileByteSource source;

    setUp(() async {
      source = await FileByteSource.open(id: 'local-1', path: path);
    });

    tearDown(() => source.close());

    test('readShouldContinueFromPreviousReadIfPositionIsNotGiven', () async {
      await source.read(2);

      expect(await source.read(2), [2, 3]);
    });

    test('readShouldReadFromPositionIfPositionIsGiven', () async {
      expect(await source.read(2, position: 3), [3, 4]);
    });

    test('readShouldReturnFewerBytesIfFewerAreLeft', () async {
      expect(await source.read(4, position: 4), [4, 5]);
    });

    test('readShouldThrowRangeErrorIfPositionIsNegative', () {
      expect(source.read(2, position: -1), throwsRangeError);
    });

    test('readShouldThrowReadExceptionIfFileFails', () async {
      await source.close();

      expect(source.read(2), throwsA(isA<ReadException>()));
    });
  });

  group('readAll', () {
    late FileByteSource source;

    setUp(() async {
      source = await FileByteSource.open(id: 'local-1', path: path);
    });

    tearDown(() => source.close());

    test(
      'readAllShouldReadToEndFromCurrentPositionIfPositionIsNotGiven',
      () async {
        await source.read(2);

        expect(await source.readAll(), [2, 3, 4, 5]);
      },
    );

    test('readAllShouldReadToEndFromPositionIfPositionIsGiven', () async {
      expect(await source.readAll(position: 4), [4, 5]);
    });

    test('readAllShouldThrowRangeErrorIfPositionIsNegative', () {
      expect(source.readAll(position: -1), throwsRangeError);
    });

    test('readAllShouldThrowReadExceptionIfFileFails', () async {
      await source.close();

      expect(source.readAll(), throwsA(isA<ReadException>()));
    });
  });

  test('closeShouldNotThrowIfAlreadyClosed', () async {
    final source = await FileByteSource.open(id: 'local-1', path: path);
    await source.close();

    await expectLater(source.close(), completes);
  });
}
