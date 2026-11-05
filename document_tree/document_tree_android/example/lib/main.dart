import 'dart:io';

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
        appBar: AppBar(title: const Text('document_tree_android example')),
        body: const TreePage(),
      ),
    );
  }
}

class TreePage extends StatefulWidget {
  const TreePage({super.key});

  @override
  State<TreePage> createState() => _TreePageState();
}

class _TreePageState extends State<TreePage> {
  final _documentTree = DocumentTreeAndroid();

  /// The last tree picked, kept as the app would store it.
  String? _treeUri;
  DocumentTree? _tree;
  List<DocumentInfo>? _documents;
  DocumentInfo? _copied;
  String? _error;

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
      setState(() => _error = null);
    } on Exception catch (e) {
      setState(() => _error = '$e');
    }
  }

  Future<void> _pick() => _run(() async {
    final tree = await _documentTree.pickTree(
      PickTreeRequest(initialUri: _treeUri),
    );
    if (tree == null) {
      return;
    }

    // Release the old tree, unless the same one was picked again.
    final oldTreeUri = _treeUri;
    if (oldTreeUri != null && oldTreeUri != tree.uri) {
      await _documentTree.releaseTree(oldTreeUri);
    }
    setState(() {
      _treeUri = tree.uri;
      _tree = tree;
    });
  });

  Future<void> _refresh() => _run(() async {
    final treeUri = _treeUri;
    if (treeUri == null) {
      return;
    }

    final tree = await _documentTree.getTree(treeUri);
    setState(() => _tree = tree);
  });

  Future<void> _release() => _run(() async {
    final treeUri = _treeUri;
    if (treeUri == null) {
      return;
    }

    await _documentTree.releaseTree(treeUri);
    final tree = await _documentTree.getTree(treeUri);
    setState(() => _tree = tree);
  });

  Future<void> _list() => _run(() async {
    final treeUri = _treeUri;
    if (treeUri == null) {
      return;
    }

    final documents = await _documentTree.listDocuments(
      ListDocumentsRequest(treeUri: treeUri, recursive: true),
    );
    setState(
      () => _documents = documents..sort((a, b) => a.path.compareTo(b.path)),
    );
  });

  /// Copies a fresh cache file into the tree, at `copy-test/sample.txt`.
  Future<void> _copy({required bool overwrite}) => _run(() async {
    final treeUri = _treeUri;
    if (treeUri == null) {
      return;
    }

    final source = File('${Directory.systemTemp.path}/sample.txt');
    await source.writeAsString('Copied at ${DateTime.now()}\n');
    final copied = await _documentTree.copyDocument(
      CopyDocumentRequest(
        sourceUri: source.uri.toString(),
        treeUri: treeUri,
        path: 'copy-test/sample.txt',
        overwrite: overwrite,
      ),
    );
    setState(() => _copied = copied);
  });

  String _formatMillis(int? millis) {
    return millis == null
        ? 'unknown'
        : '${DateTime.fromMillisecondsSinceEpoch(millis)}';
  }

  @override
  Widget build(BuildContext context) {
    final tree = _tree;
    final error = _error;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 8,
          children: [
            FilledButton(onPressed: _pick, child: const Text('Pick')),
            OutlinedButton(onPressed: _refresh, child: const Text('Refresh')),
            OutlinedButton(onPressed: _release, child: const Text('Release')),
            OutlinedButton(onPressed: _list, child: const Text('List')),
            OutlinedButton(
              onPressed: () => _copy(overwrite: false),
              child: const Text('Copy'),
            ),
            OutlinedButton(
              onPressed: () => _copy(overwrite: true),
              child: const Text('Copy (overwrite)'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (tree == null)
          Text(_treeUri == null ? 'No tree' : 'Tree unavailable: $_treeUri')
        else ...[
          Text('Name: ${tree.displayName}'),
          Text('URI: ${tree.uri}'),
          Text('Can write: ${tree.canWrite}'),
          Text('Granted at: ${_formatMillis(tree.grantedAtInMillis)}'),
          Text('Last modified: ${_formatMillis(tree.lastModifiedInMillis)}'),
          Text(
            'Location: ${tree.location == null ? 'not on device storage' : '${tree.location!.volumeId} / "${tree.location!.relativePath}"'}',
          ),
        ],
        if (_copied case final copied?) ...[
          const SizedBox(height: 16),
          Text(
            'Copied: ${copied.path} · ${copied.sizeInBytes} B · '
            '${copied.mimeType} · ${_formatMillis(copied.lastModifiedInMillis)}',
          ),
        ],
        if (_documents case final documents?) ...[
          const SizedBox(height: 16),
          Text('Documents: ${documents.length}'),
          for (final document in documents.take(50))
            Text(
              '${document.path} · ${document.isDirectory ? 'folder' : '${document.sizeInBytes} B'} · '
              '${document.canWrite ? 'writable' : 'read-only'}',
            ),
        ],
        if (error != null) ...[
          const SizedBox(height: 16),
          Text(error, style: const TextStyle(color: Colors.red)),
        ],
      ],
    );
  }
}
