import 'package:analyzer/dart/element/type.dart';
import 'package:equatable/equatable.dart';

/// Represents the signature of a parameter in a Dart function or constructor.
///
/// This class encapsulates all the key information about a parameter,
/// including its type, name, and whether it's named or required.
/// It provides a simplified view of parameter information extracted from
/// the analyzer's more complex structures.
class ParameterSignature extends Equatable {
  /// The data type of this parameter.
  ///
  /// Can be null in cases where the type is implicit (using `dynamic`)
  /// or when type information couldn't be resolved by the analyzer.
  final DartType? type;

  /// The name of this parameter.
  ///
  /// - For positional parameters, this is the identifier used in the
  ///   function body.
  /// - For named parameters, this is the key used when calling the function.
  final String name;

  /// Whether this parameter is a named parameter.
  ///
  /// Named parameters are specified with curly braces `{}` or with the
  /// `required` keyword in the function declaration and are called using
  /// the parameter name (e.g., `function(name: value)`).
  /// If false, the parameter is positional.
  final bool isNamed;

  /// Whether this parameter is required.
  ///
  /// A parameter is required when:
  /// - It's a positional parameter without a default value
  /// - It's a named parameter marked with the `required` keyword
  ///
  /// Required parameters must be provided when calling the function.
  final bool isRequired;

  /// Creates a new [ParameterSignature] with the specified properties.
  ///
  /// Parameters:
  /// - [type] - The data type of the parameter, or null if dynamic/unresolved
  /// - [name] - The name of the parameter
  /// - [isNamed] - Whether this is a named parameter (vs. positional)
  /// - [isRequired] - Whether this parameter must be provided when calling
  ///   the function
  const ParameterSignature({
    required this.type,
    required this.name,
    required this.isNamed,
    required this.isRequired,
  });

  @override
  List<Object?> get props => [type, name, isNamed, isRequired];
}
