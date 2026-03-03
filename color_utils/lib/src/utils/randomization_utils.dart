import 'dart:math';
import 'dart:ui';

final class RandomizationUtils {
  RandomizationUtils._();

  static Color random(double opacity) {
    assert(
      opacity >= 0.0 && opacity <= 1.0,
      '`opacity` must be >= 0 and <= 1.0',
    );

    return Color.fromRGBO(
      Random().nextInt(256),
      Random().nextInt(256),
      Random().nextInt(256),
      opacity,
    );
  }
}
