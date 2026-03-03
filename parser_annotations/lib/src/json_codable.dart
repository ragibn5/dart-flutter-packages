/// An annotation used to mark a class as compatible with `JsonParser`.
///
/// **Parameters:**
/// - [autoRegister]: If `true`, automatically registers the class's decoder
/// (`fromJson`) in the `JsonParser` registry. You have to set up the parser
/// registry builders (if not already) for this to work.
/// - [requireToJson]: If `true`, enforces the presence of a `toJson` method.
/// - [requireFromJson]: If `true`, enforces the presence of `fromJson` method.
class JsonCodable {
  /// Whether to automatically register the class in the parser registry.
  final bool autoRegister;

  /// The keys of the target json parsers where the annotated model should be
  /// registered in. If defined, this must match the parser keys defined under
  /// `json_parser_config.parsers` in the `parser_config.yaml` file.
  ///
  /// If not defined (i.e, empty), the default config will be used.
  /// The default config is read from `json_parser_config.default`.
  ///
  /// Note, this has no effect if `autoRegister` is set to false.
  final Set<String>? parserKeys;

  /// Whether the class must have a `JsonParser` compatible `toJson` method.
  final bool requireToJson;

  /// Whether the class must have a `JsonParser` compatible `fromJson` method.
  final bool requireFromJson;

  /// Creates a [JsonCodable] annotation with optional constraints.
  const JsonCodable({
    this.autoRegister = true,
    this.parserKeys = const {},
    this.requireToJson = true,
    this.requireFromJson = true,
  });
}
