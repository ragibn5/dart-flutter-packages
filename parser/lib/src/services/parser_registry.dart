import 'package:meta/meta.dart';
import 'package:parser/src/types/types.dart';

class ParserRegistry<I> {
  final Map<Type, Coder<I, dynamic>> _parserMap;

  ParserRegistry() : this._({});

  @visibleForTesting
  ParserRegistry.test(Map<Type, Coder<I, dynamic>> parserMap)
      : this._(parserMap);

  ParserRegistry._(this._parserMap);

  /// **Get the decoder for the requested type.**
  /// <br>
  /// You must specify the type parameter,
  /// otherwise it may return null, or generic type.
  ///
  /// If a decoded was added earlier (with [addDecoder] method call),
  /// it is guaranteed to return the decoder for that type, otherwise
  /// it returns null.
  Coder<I, ResultType>? getDecoder<ResultType>() {
    final parser = _parserMap[ResultType];
    if (parser != null) {
      return parser as Coder<I, ResultType>;
    } else {
      return null;
    }
  }

  /// **Adds a the supplied decoder to the supported decoder list.**
  /// <br>
  /// Later, the decoder will internally use this to decode
  /// the encoded data to the expected type. If the decoder
  /// was not added, you should throw an exception or take a similar action.
  void addDecoder<ResultType>(Coder<I, ResultType> decoder) {
    _parserMap[ResultType] = decoder;
  }
}
