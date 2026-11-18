import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_byte_source.dart';

void main() {
  test('readToEndShouldJoinPiecesIfSeveralAreRead', () async {
    final source = FakeByteSource(
      pieces: [
        [1, 2],
        [3],
      ],
    );

    expect(await source.callReadToEnd(2), [1, 2, 3]);
  });

  test('readToEndShouldRequestPieceSizeOnEveryRead', () async {
    final source = FakeByteSource(
      pieces: [
        [1, 2],
        [3],
      ],
    );

    await source.callReadToEnd(2);

    expect(source.readLengths, [2, 2, 2]);
  });

  test('readToEndShouldReturnEmptyIfFirstReadIsEmpty', () async {
    expect(await FakeByteSource().callReadToEnd(2), isEmpty);
  });
}
