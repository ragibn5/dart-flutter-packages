class ThirdPartyImportConfig {
  final List<String> excludedLibraryPackages;

  const ThirdPartyImportConfig({this.excludedLibraryPackages = const []});

  Map<String, dynamic> toMap() => {
    'excludedLibraryPackages': excludedLibraryPackages,
  };
}
