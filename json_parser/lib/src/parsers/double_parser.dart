import 'package:json_parser/src/types/json_types.dart';
import 'package:parser/parser.dart';

class DoubleParser implements Parser<double, Json> {
  const DoubleParser();

  @override
  double decode(Json encoded) {
    if (encoded is! num) {
      throw StateError('Expected number, but got ${encoded.runtimeType}');
    }

    return encoded.toDouble();
  }

  @override
  Json encode(double value) => value;
}
