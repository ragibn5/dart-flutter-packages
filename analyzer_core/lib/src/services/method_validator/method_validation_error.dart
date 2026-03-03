import 'package:analyzer_core/src/services/commons/validation_error.dart';
import 'package:analyzer_core/src/services/parameter_validator/parameter_validation_error.dart';

sealed class MethodValidationError extends ValidationError {
  MethodValidationError({required super.message});
}

final class MethodAccessModifierMismatch extends MethodValidationError {
  MethodAccessModifierMismatch({required super.message});
}

final class MethodNameMismatch extends MethodValidationError {
  MethodNameMismatch({required super.message});
}

final class MethodReturnTypeMismatch extends MethodValidationError {
  MethodReturnTypeMismatch({required super.message});
}

final class MethodParameterMismatch extends MethodValidationError {
  final ParameterValidationError parameterValidationError;

  MethodParameterMismatch({
    required this.parameterValidationError,
  }) : super(message: parameterValidationError.message);
}
