class DartSDKImportConfig {
  final List<String> excludedDartPackages;

  const DartSDKImportConfig({this.excludedDartPackages = const []});

  Map<String, dynamic> toMap() => {
    'excludedDartPackages': excludedDartPackages,
  };
}
