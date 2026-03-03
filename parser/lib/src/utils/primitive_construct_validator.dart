import 'package:parser/src/exceptions/overflow_exception.dart';

class PrimitiveConstructValidator {
  bool isPrimitiveConstruct(dynamic data, {int maxDepth = 10}) {
    // ignore: avoid_redundant_argument_values
    return _checkPrimitiveConstruct(data, depth: 0, maxDepth: maxDepth);
  }

  bool _checkPrimitiveConstruct(
    dynamic data, {
    int depth = 0,
    int maxDepth = 32,
  }) {
    // Check depth first
    if (depth > maxDepth) {
      Error.throwWithStackTrace(
        OverflowException(
          'Max depth of $maxDepth exceeded during primitive construct check.',
        ),
        StackTrace.current,
      );
    }

    // Primitive check
    if (_isPrimitive(data)) {
      return true;
    }

    if (data is List) {
      return data.every(
        (item) => _checkPrimitiveConstruct(
          item,
          depth: depth + 1,
          maxDepth: maxDepth,
        ),
      );
    }

    if (data is Set) {
      return data.every(
        (item) => _checkPrimitiveConstruct(
          item,
          depth: depth + 1,
          maxDepth: maxDepth,
        ),
      );
    }

    if (data is Map) {
      return data.keys.every(_isPrimitive) &&
          data.values.every(
            (value) => _checkPrimitiveConstruct(
              value,
              depth: depth + 1,
              maxDepth: maxDepth,
            ),
          );
    }

    return false;
  }

  bool _isPrimitive(dynamic data) {
    return data == null ||
        data is bool ||
        data is int ||
        data is double ||
        data is String ||
        data is num;
  }
}
