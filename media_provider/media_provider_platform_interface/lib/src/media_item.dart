import 'package:meta/meta.dart';

@immutable
class MediaItem {
  final String id;
  final String name;
  final String mimeType;
  final int sizeInBytes;
  final DateTime dateCreated;
  final DateTime dateModified;
  final String path;

  const MediaItem({
    required this.id,
    required this.name,
    required this.mimeType,
    required this.sizeInBytes,
    required this.dateCreated,
    required this.dateModified,
    required this.path,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'mimeType': mimeType,
      'sizeInBytes': sizeInBytes,
      'dateCreated': dateCreated,
      'dateModified': dateModified,
      'path': path,
    };
  }

  factory MediaItem.fromMap(Map<String, dynamic> map) {
    return MediaItem(
      id: map['id'] as String,
      name: map['name'] as String,
      mimeType: map['mimeType'] as String,
      sizeInBytes: map['sizeInBytes'] as int,
      dateCreated: map['dateCreated'] as DateTime,
      dateModified: map['dateModified'] as DateTime,
      path: map['path'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          mimeType == other.mimeType &&
          sizeInBytes == other.sizeInBytes &&
          dateCreated == other.dateCreated &&
          dateModified == other.dateModified &&
          path == other.path;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    mimeType,
    sizeInBytes,
    dateCreated,
    dateModified,
    path,
  );

  @override
  String toString() {
    return 'MediaItem{'
        'id: $id, name: $name, mimeType: $mimeType, sizeInBytes: $sizeInBytes,'
        ' dateCreated: $dateCreated, dateModified: $dateModified, path: $path}';
  }
}
