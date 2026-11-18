import 'dart:async';
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
              trailing: IconButton(
                icon: const Icon(Icons.image),
                onPressed: () => _readThumbnail(file),
              ),
            ),
      ],
    );
  }
}
