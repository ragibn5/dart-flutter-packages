class DependencyDirectionRuleConfig {
  final String domainDirName;
  final bool excludeCoreDartPackages;
  final List<String> excludedProjectPaths;
  final List<String> excludedLibraryPackages;

  const DependencyDirectionRuleConfig({
    this.domainDirName = 'domain',
    this.excludeCoreDartPackages = true,
    this.excludedProjectPaths = const [],
    this.excludedLibraryPackages = const [],
  });

  Map<String, dynamic> toMap() => {
    'excludeCoreDartPackages': excludeCoreDartPackages,
    'domainDirName': domainDirName,
    'excludedProjectPaths': excludedProjectPaths,
    'excludedLibraryPackages': excludedLibraryPackages,
  };
}
