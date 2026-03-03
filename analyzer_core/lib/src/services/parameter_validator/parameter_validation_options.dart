import 'package:equatable/equatable.dart';

class ParameterValidationOptions extends Equatable {
  final bool ignoreType;
  final bool ignoreName;
  final bool ignoreRequiredStatus;
  final bool ignoreNamedStatus;

  const ParameterValidationOptions({
    this.ignoreType = false,
    this.ignoreName = true,
    this.ignoreRequiredStatus = false,
    this.ignoreNamedStatus = false,
  });

  @override
  List<Object> get props => [
        ignoreType,
        ignoreName,
        ignoreRequiredStatus,
        ignoreNamedStatus,
      ];

  @override
  bool? get stringify => true;
}
