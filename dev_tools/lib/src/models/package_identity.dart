import 'package:meta/meta.dart';

/// The identity of dart/flutter package.
@immutable
class PackageIdentity {
  final String name;

  /// The package's version, or null when its pubspec has none — a valid,
  /// ordinary state for an internal/unreleased package (e.g. an app), not
  /// an error.
  final String? version;

  /// Whether this package could actually be published: it doesn't opt out
  /// via `publish_to: none`, AND it has a [version] — pub.dev requires one
  /// to host a package at all, so a versionless package can never be
  /// published regardless of `publish_to`. This is the single source of
  /// truth for "is this releasable" — callers should not also check
  /// `version != null` separately alongside it.
  final bool isPublishable;
  final bool isFlutterPackage;

  const PackageIdentity({
    required this.name,
    required this.version,
    this.isPublishable = true,
    this.isFlutterPackage = false,
  });

  @override
  bool operator ==(Object other) =>
      other is PackageIdentity &&
      other.name == name &&
      other.version == version &&
      other.isPublishable == isPublishable &&
      other.isFlutterPackage == isFlutterPackage;

  @override
  int get hashCode =>
      Object.hash(name, version, isPublishable, isFlutterPackage);
}
