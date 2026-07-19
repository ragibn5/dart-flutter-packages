/// Context for a source unit that lives inside a domain directory.
///
/// Holds both the unit's package-root-relative path and the
/// package-root-relative path of the domain directory that contains it.
class DomainUnitContext {
  /// Package-root-relative path of the unit.
  ///
  /// e.g. `lib/feature/auth/domain/services/auth_service.dart`
  final String unitPath;

  /// Package-root-relative path of the domain directory that
  /// contains the [unitPath].
  ///
  /// e.g. `lib/feature/auth/domain/`
  final String domainDirPath;

  const DomainUnitContext(this.unitPath, this.domainDirPath);
}
