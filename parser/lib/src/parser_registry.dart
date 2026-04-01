import 'package:meta/meta.dart';
import 'package:parser/src/parser.dart';

abstract class ParserRegistry<E> {
  final Map<Type, Parser<Object?, E>> _parserMap;

  ParserRegistry() : this._({});

  @visibleForTesting
  const ParserRegistry.test(Map<Type, Parser<Object?, E>> parserMap)
      : this._(parserMap);

  const ParserRegistry._(this._parserMap);

  @visibleForTesting
  Map<Type, Parser<Object?, E>> get parserMap => _parserMap;

  /// Registers a parser for the type [T].
  void addParser<T extends Object?>(Parser<T, E> parser) {
    _parserMap[T] = parser;
  }

  /// Returns the parser for the type [T],
  /// or null if no parser was registered the for type [T].
  Parser<T, E>? getParser<T extends Object?>() {
    return _parserMap[T] as Parser<T, E>?;
  }

  /// Returns the parser for the type [typeOfT],
  /// or null if no parser was registered the for type [typeOfT].
  ///
  /// Note, this should only be used in special cases
  /// when the type [typeOfT] is not known at compile time.
  Parser<Object?, E>? getRuntimeParser(Type typeOfT) {
    return _parserMap[typeOfT];
  }
}
