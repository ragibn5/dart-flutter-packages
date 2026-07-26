class CrossLayerImportConfig {
  final List<String> excludedProjectPaths;

  const CrossLayerImportConfig({this.excludedProjectPaths = const []});

  Map<String, dynamic> toMap() => {
    'excludedProjectPaths': excludedProjectPaths,
  };
}
