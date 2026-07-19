class DependencyDirectionRuleConfig {
  final bool excludeCoreDartPackages;
  final List<String> domainDirNames;
  final List<String> excludedProjectPaths;
  final List<String> excludedLibraryPackages;

  const DependencyDirectionRuleConfig({
    this.excludeCoreDartPackages = true,
    this.domainDirNames = const ['domain'],
    this.excludedProjectPaths = const [],
    this.excludedLibraryPackages = const [],
  });

  Map<String, dynamic> toMap() => {
    'excludeCoreDartPackages': excludeCoreDartPackages,
    'domainDirNames': domainDirNames,
    'excludedProjectPaths': excludedProjectPaths,
    'excludedLibraryPackages': excludedLibraryPackages,
  };
}
