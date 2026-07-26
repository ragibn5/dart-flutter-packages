class DomainConfig {
  final List<String> domainDirNames;

  const DomainConfig({this.domainDirNames = const ['domain']});

  Map<String, dynamic> toMap() => {'domainDirNames': domainDirNames};
}
