import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:content_io_android/content_io_android.dart';
import 'package:document_tree_android/document_tree_android.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('content_io_android example')),
        body: const ContentPage(),
      ),
    );
  }
}

class ContentPage extends StatefulWidget {
  const ContentPage({super.key});

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  final _contentIo = ContentIoAndroid();
  final _documentTree = DocumentTreeAndroid();

  String? _treeUri;
  List<DocumentInfo>? _files;
  String? _result;
  Uint8List? _thumbnail;
  String? _error;

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
      setState(() => _error = null);
    } on Exception catch (e) {
      setState(() => _error = '$e');
    }
  }

  /// Lets the user pick a folder, then lists the files in it.
  Future<void> _pick() => _run(() async {
    final tree = await _documentTree.pickTree(
      PickTreeRequest(initialUri: _treeUri),
    );
    if (tree == null) {
      return;
    }

    setState(() => _treeUri = tree.uri);
    await _list();
  });

  Future<void> _list() async {
    final treeUri = _treeUri;
    if (treeUri == null) {
      return;
    }

    final documents = await _documentTree.listDocuments(
      ListDocumentsRequest(treeUri: treeUri, recursive: true),
    );
    setState(
      () => _files =
          documents.where((e) => !e.isDirectory).toList()
            ..sort((a, b) => a.path.compareTo(b.path)),
    );
  }

  /// Streams all of [file]'s bytes, counting them.
  Future<void> _read(DocumentInfo file) => _run(() async {
    final watch = Stopwatch()..start();
    final session = await _contentIo.openReadSession(
      OpenReadRequest(uri: file.uri),
    );
    var count = 0;
    await for (final chunk in session.openRead()) {
      count += chunk.length;
    }
    setState(
      () => _result =
          'Read ${file.path}: $count of ${session.sizeInBytes} bytes '
          'in ${watch.elapsedMilliseconds} ms',
    );
  });

  /// Creates `written.txt` in the folder, then writes it with a session;
  /// fails if it's already there.
  Future<void> _write() => _run(() async {
    final treeUri = _treeUri;
    if (treeUri == null) {
      return;
    }

    final created = await _documentTree.createDocument(
      CreateDocumentRequest(treeUri: treeUri, path: 'written.txt'),
    );
    final session = await _contentIo.openWriteSession(
      OpenWriteRequest(uri: created.uri),
    );
    for (var line = 1; line <= 3; line++) {
      await session.write(utf8.encode('Line $line, at ${DateTime.now()}\n'));
    }
    await session.close();
    setState(() => _result = 'Wrote ${created.path}');
    await _list();
  });

  /// Adds a line to the end of [file].
  Future<void> _append(DocumentInfo file) => _run(() async {
    final session = await _contentIo.openWriteSession(
      OpenWriteRequest(uri: file.uri, mode: WriteMode.append),
    );
    await session.write(utf8.encode('Appended at ${DateTime.now()}\n'));
    await session.close();
    setState(() => _result = 'Appended to ${file.path}');
    await _list();
  });

  /// Reads [file]'s thumbnail, if its provider has one.
  Future<void> _readThumbnail(DocumentInfo file) => _run(() async {
    final session = await _contentIo.openThumbnailReadSession(
      OpenThumbnailReadRequest(
        uri: file.uri,
        size: const ThumbnailSize(width: 256, height: 256),
      ),
    );
    final bytes = await session.readAsBytes();
    setState(() {
      _thumbnail = bytes;
      _result = 'Thumbnail of ${file.path}: ${bytes.length} bytes';
    });
  });

  @override
  Widget build(BuildContext context) {
    final files = _files;
    final thumbnail = _thumbnail;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 8,
          children: [
            ElevatedButton(onPressed: _pick, child: const Text('Pick')),
            ElevatedButton(
              onPressed: () => _run(_list),
              child: const Text('List'),
            ),
            ElevatedButton(onPressed: _write, child: const Text('Write')),
          ],
        ),
        if (_error case final error?)
          Text(error, style: const TextStyle(color: Colors.red)),
        if (_result case final result?) Text(result),
        if (thumbnail != null) Image.memory(thumbnail, height: 128),
        if (files != null)
          for (final file in files)
            ListTile(
              title: Text(file.path),
              subtitle: Text('${file.sizeInBytes} bytes'),
              onTap: () => _read(file),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _append(file),
                  ),
                  IconButton(
                    icon: const Icon(Icons.image),
                    onPressed: () => _readThumbnail(file),
                  ),
                ],
              ),
            ),
      ],
    );
  }
}
