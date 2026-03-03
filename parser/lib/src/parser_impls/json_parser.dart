import 'dart:convert';

import 'package:parser/parser.dart';
import 'package:parser/src/utils/built_in_type_validator.dart';
import 'package:parser/src/utils/primitive_construct_validator.dart';
import 'package:string_extensions/string_extensions.dart';

/// ### A serializer/deserializer for encoding/decoding to/from json.
///
/// It supports serialization/deserialization of supported primitive constructs
/// out of the box. Please see the [PrimitiveConstructValidator] class to know
/// more about the supported primitive constructs.
///
/// For custom types, it expects the encoder and decoder to be strictly in the
/// following form (T is the type in question):
///
/// Encoder(as an instance method):
/// ```dart
/// Map<String, dynamic> toJson() { ... }
/// ```
/// Decoder(as a dart factory constructor):
/// ```dart
/// factory T.fromJson(Map<String, dynamic>) { ... }
/// ```
///
/// The methods of this class may throw [ParseException].
/// Consider catching and/or print them, or handle them accordingly.
class JsonParser extends Parser<Map<String, dynamic>> {
  final _builtInTypeValidator = BuiltInTypeValidator();
  final _primitiveConstructValidator = PrimitiveConstructValidator();

  /// **Get the encoded form of the given data.**
  /// - If it is a supported primitive construct, returns as it is.
  ///   To know more about the supported construct, please see the
  ///   [PrimitiveConstructValidator] class.
  /// - Otherwise, this method expects that the class of [data]
  ///   contains an encoder method strictly of the following form
  ///   (as an instance method):
  ///   ```dart
  ///   Map<String, dynamic> toJson() { ... }
  ///   ```
  ///
  /// Throws [ParseException] on following scenarios:
  /// - The argument class does not contain a compatible encoder method.
  /// - Was unable to encode the argument in any way.
  ///
  @override
  dynamic encode(dynamic data) {
    if (_primitiveConstructValidator.isPrimitiveConstruct(data)) {
      return data;
    }

    dynamic initialEncodedForm;
    try {
      // ignore: avoid_dynamic_calls
      initialEncodedForm = data.toJson();
    } catch (e, st) {
      Error.throwWithStackTrace(_buildEncoderNotFoundException(e, st), st);
    }

    if (initialEncodedForm is! Map<String, dynamic>) {
      Error.throwWithStackTrace(
        _buildUnsupportedEncoderSignatureException(initialEncodedForm),
        StackTrace.current,
      );
    }

    try {
      // We first call jsonEncode on the data.
      // The main purpose of doing this is that this process
      // also expands any nested custom type to their json form.
      //
      // Finally we decode the expanded form back.
      // This gives us a fully expanded and decoded json object.

      // ignore: avoid_dynamic_calls
      final normalized = jsonEncode(initialEncodedForm);
      return jsonDecode(normalized);
    } catch (e, st) {
      Error.throwWithStackTrace(_buildUnexpectedEncodingException(e, st), st);
    }
  }

  /// **Get the decoded form of the given data [data] (as [ResultType]).**
  ///
  /// - If it is a supported primitive construct, and it's runtime type is
  ///   same as [ResultType], it is returned as it is. To know more about the
  ///   supported construct, please see the [PrimitiveConstructValidator] class.
  /// - Else, tries to decode the the data to the specified type.
  ///   In this case, this method expects that [ResultType] contains a
  ///   decoder method strictly of the following form
  ///   (as an instance method):
  ///   ```dart
  ///   Map<String, dynamic> toJson() { ... }
  ///   ```
  ///
  /// In either case the return type should strictly be the specified type.
  ///
  /// Throws [ParseException] on following scenarios:
  /// - In case of primitive construct, if the [ResultType]
  ///   is not same as the runtime type of the given [data].
  /// - In case of custom type:
  ///   - If the decoder of [ResultType] is not registered.
  ///   - If there were any error decoding [data] to the [ResultType].
  /// - If the data is a [List] of some custom type.
  ///   The package does not support (also, this is discouraged)
  ///   decoding list or any collection type of custom types.
  ///   If you absolutely need to provide such support, you need
  ///   to build your own parser extending [Parser].
  ///
  /// Currently, decoding is supported for these types:
  /// - Primitive types (bool, num, String).
  /// - Lists of primitive types (List<bool>, List<num>, List<String>).
  /// - Maps with primitive keys and values (Map<Primitive, Primitive>).
  @override
  ResultType decode<ResultType>(dynamic data) {
    if (_builtInTypeValidator.isBuiltInType(ResultType)) {
      if (!_primitiveConstructValidator.isPrimitiveConstruct(data)) {
        Error.throwWithStackTrace(
          _buildUnsupportedDataWhileDecodingException(),
          StackTrace.current,
        );
      }

      try {
        return data as ResultType;
      } catch (e, st) {
        Error.throwWithStackTrace(
          _buildTypeMismatchWhileDecodingException(data, ResultType, e, st),
          st,
        );
      }
    } else if (data is Map<String, dynamic>) {
      final parser = getDecoder<ResultType>();
      if (parser == null) {
        Error.throwWithStackTrace(
          _buildDecoderNotFoundException(ResultType),
          StackTrace.current,
        );
      }

      try {
        return parser(data);
      } catch (e, st) {
        Error.throwWithStackTrace(
          _buildUnexpectedDecodingException(data, ResultType, e, st),
          st,
        );
      }
    } else {
      Error.throwWithStackTrace(
        _buildUnsupportedDataWhileDecodingException(),
        StackTrace.current,
      );
    }
  }

  ParseException _buildEncoderNotFoundException(
    dynamic exception,
    StackTrace stackTrace,
  ) {
    return ParseException(
      '''
      Couldn't find compatible encoder method within the passed argument.
      Ensure that the class of the object you are trying to encode
      contains an encoder method strictly of the following signature:
      ```dart
      Map<String, dynamic> toJson() { ... }
      ```
      '''
          .trimLines(),
      sourceException: exception,
      sourceExceptionStackTrace: stackTrace,
    );
  }

  ParseException _buildUnsupportedEncoderSignatureException(
    dynamic initialEncodedForm,
  ) {
    return ParseException(
      '''
      Invalid or unsupported encoder signature.
      Ensure that the class of the object you are trying to encode
      contains an encoder method strictly of the following signature:
      ```dart
      Map<String, dynamic> toJson() { ... }
      ```
      
      Expected return type was: Map<String, dynamic>
      Found: ${initialEncodedForm.runtimeType}
      '''
          .trimLines(),
    );
  }

  ParseException _buildUnexpectedEncodingException(
    dynamic exception,
    StackTrace stackTrace,
  ) {
    return ParseException(
      'Unexpected error while encoding the argument.',
      sourceException: exception,
      sourceExceptionStackTrace: stackTrace,
    );
  }

  ParseException _buildTypeMismatchWhileDecodingException(
    dynamic data,
    Type expectedType,
    dynamic exception,
    StackTrace? stackTrace,
  ) {
    return ParseException(
      '''
      Type mismatch during decoding.
      Expected type: `$expectedType`
      Received type: `${data.runtimeType}`.
      '''
          .trimLines(),
      sourceException: exception,
      sourceExceptionStackTrace: stackTrace,
    );
  }

  ParseException _buildUnsupportedDataWhileDecodingException() {
    return ParseException(
      '''
      Unsupported data type for decoding, only the following are supported:
      - Primitive types (bool, num, String)
      - Lists of primitive types (List<bool>, List<num>, List<String>)
      - Maps with primitive keys and values (Map<Primitive, Primitive>)
      '''
          .trimLines(),
    );
  }

  ParseException _buildDecoderNotFoundException(Type expectedType) {
    return ParseException(
      '''
      Could not find the decoder for type: `$expectedType`.
      Ensure you have registered the decoder for this type.
      
      A decoder is typically of the form (standard, and recommended):
      ```dart
      factory T.fromJson(Map<String, dynamic>) { ... }
      ```
      
      You must register a type as following in order for the decoding to work.
      (Assuming the decoder has the form specified above)
      ```dart
      thisParserInstance.addDecoder($expectedType.fromJson)
      ```
      '''
          .trimLines(),
    );
  }

  ParseException _buildUnexpectedDecodingException(
    dynamic data,
    Type expectedType,
    dynamic exception,
    StackTrace stackTrace,
  ) {
    return ParseException(
      '''
      Failed to parse the argument to the target type: `$expectedType`.
      - Please verify that the structure of the argument matches the expected format for `$expectedType`.
      - Check the decoder (`$expectedType.fromJson(...)`) implementation for `$expectedType` for any errors.

      Passed argument:
      ${const JsonEncoder.withIndent('  ').convert(data)}
      '''
          .trimLines(),
      sourceException: exception,
      sourceExceptionStackTrace: stackTrace,
    );
  }
}
