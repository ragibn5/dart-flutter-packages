class MultipartFilePart {
  /// Multipart field name that this file belongs to.
  final String fieldName;

  /// File name reported to the server.
  final String fileName;

  /// In-memory file contents.
  final List<int> bytes;

  const MultipartFilePart({
    required this.fieldName,
    required this.fileName,
    required this.bytes,
    this.contentType,
  });

  /// Optional MIME type, for example `image/jpeg`.
  final String? contentType;
}
