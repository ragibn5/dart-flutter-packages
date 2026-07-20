class ImportUri {
  final String? scheme;
  final String? packageName;
  final String path;

  ImportUri({this.scheme, this.packageName, required this.path});

  @override
  String toString() {
    return '${scheme != null ? '$scheme:' : ''}'
        '${packageName != null ? '$packageName/' : ''}'
        '$path';
  }
}
