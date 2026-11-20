# document_tree_android

Reads and writes folders the user picks, through Android's Storage Access Framework.

## Installation

#### From pub.dev

Add this to your `pubspec.yaml`

```yaml
dependencies:
  document_tree_android: ^2.0.0
```

#### Or, From Git repo

```yaml
dependencies:
  document_tree_android:
    git:
      url: https://github.com/ragibn5/dart-flutter-packages.git
      path: document_tree/document_tree_android
      ref: document_tree_android-2.0.0
```

## Features

- Let the user pick a folder, on any storage the system's picker offers, and keep the app's access to it across restarts.
- Check a picked folder later: whether the app still holds its grant, whether it can be written to, and where it is on the device's storage.
- List a folder's files and folders, optionally all the way down, or look up a single one.
- Create folders, and files with their content, for small files written in one go.
- Copy a file into a folder from any URI the app can read.
- Rename, move and delete files and folders.
- Every operation fails rather than replace or rename around a document that already has the name. A move can skip that check when the caller knows the name is free.
- Pass a folder's URI from an earlier result to skip finding it by its path again.

## Permissions

None: the user's pick grants the app access to that folder, and only that folder.

## Get started

```dart
final documentTree = DocumentTreeAndroid();

// 1. Let the user pick a folder; null if they cancel.
final tree = await documentTree.pickTree(const PickTreeRequest());
if (tree == null) return;

// 2. List what's in it.
final documents = await documentTree.listDocuments(
  ListDocumentsRequest(treeUri: tree.uri, path: 'DCIM', recursive: true),
);

// 3. Make a folder, and copy a file into it.
await documentTree.createDirectory(
  CreateDirectoryRequest(treeUri: tree.uri, path: 'Backup'),
);
final copy = await documentTree.copyDocument(
  CopyDocumentRequest(
    sourceUri: 'content://media/external/images/media/42',
    treeUri: tree.uri,
    path: 'Backup/IMG_42.jpg',
  ),
);

// 4. Write a small file, then rename it.
final notes = await documentTree.createDocument(
  CreateDocumentRequest(
    treeUri: tree.uri,
    path: 'Backup/notes.txt',
    bytes: utf8.encode('Copied IMG_42.jpg'),
  ),
);
await documentTree.renameDocument(
  RenameDocumentRequest(treeUri: tree.uri, path: notes.path, newName: 'log.txt'),
);

// Later: check the folder again, or give it up.
final sameTree = await documentTree.getTree(tree.uri);
await documentTree.releaseTree(tree.uri);
```

## Errors

Each operation throws its own sealed exception type, so a `switch` covers every case:

- `pickTree`: `TreePickException`, such as `PickerAlreadyOpenException` or `NoActivityException`.
- `getTree` and `releaseTree`: `TreeRequestException`, when the URI isn't a tree's.
- `listDocuments` and `getDocument`: `DocumentQueryException`, such as `TreeAccessLostException` or `DocumentNotFoundException`.
- `createDirectory`, `createDocument`, `copyDocument`, `renameDocument`, `moveDocument` and `deleteDocument`: `DocumentWriteException`, such as `TreeNotWritableException`, `DocumentAlreadyExistsException`, `DocumentNotFoundException` or `NotEnoughSpaceException`.

## Example

See the [example](example) app for a complete demonstration.
