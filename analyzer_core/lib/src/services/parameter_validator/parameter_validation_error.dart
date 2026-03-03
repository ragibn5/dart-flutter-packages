import 'package:analyzer_core/src/services/commons/validation_error.dart';

sealed class ParameterValidationError extends ValidationError {
  ParameterValidationError({required super.message});
}

final class ParameterCountMismatch extends ParameterValidationError {
  ParameterCountMismatch({required super.message});
}

final class ParameterTypeMismatch extends ParameterValidationError {
  ParameterTypeMismatch({required super.message});
}

final class ParameterNameMismatch extends ParameterValidationError {
  ParameterNameMismatch({required super.message});
}

final class ParameterRequiredMismatch extends ParameterValidationError {
  ParameterRequiredMismatch({required super.message});
}

final class ParameterNamedMismatch extends ParameterValidationError {
  ParameterNamedMismatch({required super.message});
}
