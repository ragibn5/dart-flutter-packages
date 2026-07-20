class DependencyDirectionRuleConfig {
  final bool excludeCoreDartPackages;
  final List<String> domainDirNames;

  /// Package-root-relative paths that are excluded from the rule.
  ///
  /// e.g. `['lib/core/', 'lib/shared/']`
  final List<String> excludedProjectPaths;

  /// Third-party package name prefixes that are excluded from the rule.
  ///
  /// e.g. `['dartz', 'freezed']`
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
