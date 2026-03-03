import 'package:equatable/equatable.dart';

class ConstructorValidationOptions extends Equatable {
  final bool ignoreAccessModifiers;
  final bool ignoreName;
  final bool ignoreParameterRequiredStatus;
  final bool ignoreParameterTypes;
  final bool ignoreParameterNames;

  const ConstructorValidationOptions({
    this.ignoreAccessModifiers = false,
    this.ignoreName = false,
    this.ignoreParameterRequiredStatus = false,
    this.ignoreParameterTypes = false,
    this.ignoreParameterNames = true,
  });

  @override
  List<Object> get props => [
        ignoreAccessModifiers,
        ignoreName,
        ignoreParameterRequiredStatus,
        ignoreParameterTypes,
        ignoreParameterNames,
      ];

  @override
  bool? get stringify => true;
}
