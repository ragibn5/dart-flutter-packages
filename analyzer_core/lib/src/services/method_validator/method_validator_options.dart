import 'package:equatable/equatable.dart';

class MethodValidationOptions extends Equatable {
  final bool ignoreAccessModifiers;
  final bool ignoreReturnType;
  final bool ignoreName;
  final bool ignoreParameterRequiredStatus;
  final bool ignoreParameterTypes;
  final bool ignoreParameterNames;

  const MethodValidationOptions({
    this.ignoreAccessModifiers = false,
    this.ignoreReturnType = false,
    this.ignoreName = false,
    this.ignoreParameterRequiredStatus = false,
    this.ignoreParameterTypes = false,
    this.ignoreParameterNames = true,
  });

  @override
  List<Object> get props => [
        ignoreAccessModifiers,
        ignoreReturnType,
        ignoreName,
        ignoreParameterRequiredStatus,
        ignoreParameterTypes,
        ignoreParameterNames,
      ];

  @override
  bool? get stringify => true;
}
