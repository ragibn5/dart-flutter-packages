import 'dart:io';
import 'package:file_store/file_store.dart';

void main() async {
  final store = FileStore(File('/tmp/example.txt'));
  await store.writeData('Hello, World!');

  final data = await store.readData();
  print(data);
}
