class DartSdkImportConfig {
  final List<String> excludedDartPackages;

  const DartSdkImportConfig({this.excludedDartPackages = const []});

  Map<String, dynamic> toMap() => {
    'excludedDartPackages': excludedDartPackages,
  };
}
