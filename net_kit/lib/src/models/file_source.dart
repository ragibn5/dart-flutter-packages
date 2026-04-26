sealed class FileSource {
  const FileSource();
}

final class BytesSource extends FileSource {
  final List<int> bytes;

  const BytesSource(this.bytes);
}

final class StreamSource extends FileSource {
  final int length;
  final Stream<List<int>> stream;

  const StreamSource(this.length, this.stream);
}
