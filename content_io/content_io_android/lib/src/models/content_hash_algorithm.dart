import 'package:json_annotation/json_annotation.dart';

/// An algorithm content can be hashed with.
@JsonEnum()
enum ContentHashAlgorithm {
  /// SHA-256.
  @JsonValue('sha256')
  sha256,
}
