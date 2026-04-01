/// An annotation that triggers JSON parser generation for the annotated class.
class GenerateJsonParser {
  /// Optional set of registry identifiers where the generated parser should
  /// be registered.
  ///
  /// Note:
  /// - If not provided, the generated parser will be registered in the
  ///   `default` registry. The default registry class is generally named
  ///   `DefaultJsonParserRegistry`.
  /// - If provided, the generated parser will be registered in the specified
  ///   registries. For example, if `registryKeys = {'dev', 'prod'}` the
  ///   generated parser will be registered in two registries:
  ///   - `DevJsonParserRegistry`: For `dev` key.
  ///   - `ProdJsonParserRegistry`: For `prod` key.
  ///   - Keys can be any valid strings, but -
  ///     - keys are case in-sensitive, meaning `dev`, `Dev`,
  ///       and `DEV` all will produce the same registry class,
  ///       `DevJsonParserRegistry`.
  ///     - Blank strings will be ignored.
  ///     - `default` key is reserved for the default registry and should not
  ///       be used. If used, the generated parser will be registered in the
  ///       default registry.
  /// - Pass empty set to intensionally disable registration for a particular
  ///   class.
  ///
  final Set<String> registryKeys;

  const GenerateJsonParser({this.registryKeys = const {'default'}});
}
