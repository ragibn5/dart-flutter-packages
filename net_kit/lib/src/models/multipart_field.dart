class MultipartField {
  /// Field name in the multipart payload.
  final String name;

  /// String value for the multipart field.
  final String value;

  const MultipartField({
    required this.name,
    required this.value,
  });
}
