import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_content_reader.dart';

void main() {
  test('readToEndShouldJoinPiecesIfSeveralAreRead', () async {
    final reader = FakeContentReader(
      pieces: [
        [1, 2],
        [3],
      ],
    );

    expect(await reader.callReadToEnd(2), [1, 2, 3]);
  });

  test('readToEndShouldRequestPieceSizeOnEveryRead', () async {
    final reader = FakeContentReader(
      pieces: [
        [1, 2],
        [3],
      ],
    );

    await reader.callReadToEnd(2);

    expect(reader.readLengths, [2, 2, 2]);
  });

  test('readToEndShouldReturnEmptyIfFirstReadIsEmpty', () async {
    expect(await FakeContentReader().callReadToEnd(2), isEmpty);
  });
}
