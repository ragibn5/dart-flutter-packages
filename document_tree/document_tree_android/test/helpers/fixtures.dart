import 'dart:typed_data';

import 'package:document_tree_android/document_tree_android.dart';

const treeUri =
    'content://com.android.externalstorage.documents/tree/B63B-1E04%3ASync';

const tree = DocumentTree(
  uri: treeUri,
  displayName: 'Sync',
  canWrite: true,
  location: TreeLocation(volumeId: 'B63B-1E04', relativePath: 'Sync'),
  grantedAtInMillis: 1763078400000,
  lastModifiedInMillis: null,
);

const document = DocumentInfo(
  uri: '$treeUri/document/B63B-1E04%3ASync%2FDCIM%2FIMG_1.jpg',
  path: 'DCIM/IMG_1.jpg',
  displayName: 'IMG_1.jpg',
  isDirectory: false,
  canWrite: true,
  mimeType: 'image/jpeg',
  sizeInBytes: 2048,
  lastModifiedInMillis: 1763078400000,
);

const pickRequest = PickTreeRequest(initialUri: treeUri);

const listRequest = ListDocumentsRequest(treeUri: treeUri, path: 'DCIM');

const copyRequest = CopyDocumentRequest(
  sourceUri: 'content://media/external/images/media/1',
  treeUri: treeUri,
  path: 'DCIM/IMG_1.jpg',
);

const getRequest = GetDocumentRequest(treeUri: treeUri, path: 'DCIM/IMG_1.jpg');

const createDirectoryRequest = CreateDirectoryRequest(
  treeUri: treeUri,
  path: 'DCIM',
);

final createDocumentRequest = CreateDocumentRequest(
  treeUri: treeUri,
  path: 'DCIM/notes.txt',
  mimeType: 'text/plain',
  bytes: Uint8List.fromList([1, 2, 3]),
);

const renameRequest = RenameDocumentRequest(
  treeUri: treeUri,
  path: 'DCIM/IMG_1.jpg',
  newName: 'IMG_2.jpg',
);

const moveRequest = MoveDocumentRequest(
  treeUri: treeUri,
  path: 'DCIM/IMG_1.jpg',
  newParentPath: 'Pictures',
);

const deleteRequest = DeleteDocumentRequest(
  treeUri: treeUri,
  path: 'DCIM/IMG_1.jpg',
);
