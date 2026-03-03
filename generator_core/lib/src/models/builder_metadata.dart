import 'package:build/build.dart';

abstract class BuilderMetadata<T> {
  final T data;
  final BuilderOptions options;

  BuilderMetadata(
    this.data,
    this.options,
  );
}
