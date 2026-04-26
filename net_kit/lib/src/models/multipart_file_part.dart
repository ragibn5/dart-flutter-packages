import 'package:net_kit/src/models/file_source.dart';

final class MultipartFilePart {
  final String fieldName;

  final String fileName;
  final FileSource source;

  final String? contentType;
  final Map<String, String>? headers;

  const MultipartFilePart({
    required this.fieldName,
    required this.fileName,
    required this.source,
    this.contentType,
    this.headers,
  });
}
