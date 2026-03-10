import 'package:parser/src/services/parser_registry.dart';

abstract class Parser<I> extends ParserRegistry<I> {
  /// **Encode [data].**
  /// <br>
  /// If it is a primitive construct, should return as it is.
  /// Else encode if necessary before sending to the receiver.
  dynamic encode(dynamic data);

  /// **Try to decode [data] to the specified type.**
  /// - If it is a primitive construct, return as it is.
  /// - Else, try to decode the data to the specified type.
  ///
  /// In either case the return type should strictly be the specified type.
  /// If not, an exception should be thrown, or similar action must be taken.
  ResultType decode<ResultType>(dynamic data);
}
