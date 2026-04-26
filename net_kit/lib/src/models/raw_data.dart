sealed class RawData {
  const RawData();
}

final class RawString extends RawData {
  final String value;

  const RawString(this.value);
}

final class RawBytes extends RawData {
  final List<int> bytes;

  const RawBytes(this.bytes);
}

final class RawStream extends RawData {
  final int length;
  final Stream<List<int>> stream;

  const RawStream(this.length, this.stream);
}
