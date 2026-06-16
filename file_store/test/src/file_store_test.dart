import 'dart:io';

import 'package:file_store/file_store.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('file_store_test_');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  group('readData', () {
    test('Returns null when file does not exist', () async {
      final file = File('${tempDir.path}/nonexistent.txt');
      final store = FileStore(file);

      expect(await store.readData(), isNull);
    });

    test('Returns content when file exists', () async {
      final file = File('${tempDir.path}/data.txt')
        ..writeAsStringSync('hello world');
      final store = FileStore(file);

      expect(await store.readData(), 'hello world');
    });
  });

  group('writeData', () {
    test('Writes content to file', () async {
      final file = File('${tempDir.path}/data.txt');
      final store = FileStore(file);

      await store.writeData('test content');
      expect(file.readAsStringSync(), 'test content');
    });

    test('Deletes file when content is null', () async {
      final file = File('${tempDir.path}/data.txt')
        ..writeAsStringSync('old content');
      final store = FileStore(file);

      await store.writeData(null);
      expect(file.existsSync(), isFalse);
    });

    test('Creates parent directory when missing', () async {
      final file = File('${tempDir.path}/new_dir/data.txt');
      final store = FileStore(file);

      await store.writeData('content');
      expect(file.readAsStringSync(), 'content');
    });

    test('Does not throw when deleting non-existent file', () async {
      final file = File('${tempDir.path}/nonexistent.txt');
      final store = FileStore(file);

      await store.writeData(null);
    });
  });

  group('read-write round trip', () {
    test('Write then read returns written content', () async {
      final file = File('${tempDir.path}/data.txt');
      final store = FileStore(file);

      await store.writeData('round trip');
      expect(await store.readData(), 'round trip');
    });
  });
}
