/// An annotation that triggers JSON parser generation for the annotated class.
class GenerateJsonParser {
  /// Optional set of identifiers of the registries where the generated
  /// parser should be registered.
  ///
  /// If not provided or empty, the parser class will still be generated
  /// but will not be registered in any registry.
  final Set<String>? registryKeys;

  const GenerateJsonParser({this.registryKeys = const {}});
}
