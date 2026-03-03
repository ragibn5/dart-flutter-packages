import 'package:analyzer_core/src/services/commons/validation_error.dart';
import 'package:analyzer_core/src/services/parameter_validator/parameter_validation_error.dart';

sealed class ConstructorValidationError extends ValidationError {
  ConstructorValidationError({required super.message});
}

final class ConstructorAccessModifierMismatch
    extends ConstructorValidationError {
  ConstructorAccessModifierMismatch({required super.message});
}

final class ConstructorNameMismatch extends ConstructorValidationError {
  ConstructorNameMismatch({required super.message});
}

final class ConstructorReturnTypeMismatch extends ConstructorValidationError {
  ConstructorReturnTypeMismatch({required super.message});
}

final class ConstructorParameterMismatch extends ConstructorValidationError {
  final ParameterValidationError parameterValidationError;

  ConstructorParameterMismatch({
    required this.parameterValidationError,
  }) : super(message: parameterValidationError.message);
}
