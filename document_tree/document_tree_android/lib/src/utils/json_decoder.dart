import 'dart:convert';
import 'dart:isolate';

/// Decodes a JSON object.
///
/// Parameters:
/// - [json]: the JSON object.
/// - [fromJson]: decodes the object.
///
/// Returns: the decoded object.
///
/// Throws:
/// - [FormatException] if [json] isn't valid JSON.
T decodeJsonObject<T>(
  String json,
  T Function(Map<String, dynamic> json) fromJson,
) {
  return fromJson(jsonDecode(json) as Map<String, dynamic>);
}

/// Decodes a JSON array of objects.
///
/// Parameters:
/// - [json]: the JSON array.
/// - [fromJson]: decodes one object.
///
/// Returns: the decoded objects, in order.
///
/// Throws:
/// - [FormatException] if [json] isn't valid JSON.
List<T> decodeJsonList<T>(
  String json,
  T Function(Map<String, dynamic> json) fromJson,
) {
  final items = jsonDecode(json) as List<dynamic>;
  return items.map((item) => fromJson(item as Map<String, dynamic>)).toList();
}

/// Decodes a JSON array of objects on a new isolate.
///
/// Parameters:
/// - [json]: the JSON array.
/// - [fromJson]: decodes one object; must be a top-level or static function,
///   or a constructor tear-off, so it can be sent to the new isolate.
///
/// Returns: the decoded objects, in order.
///
/// Throws:
/// - [FormatException] if [json] isn't valid JSON.
///
/// Note:
/// Top-level, so the closure sent to the new isolate captures only [json]
/// and [fromJson].
Future<List<T>> decodeJsonListInBackground<T>(
  String json,
  T Function(Map<String, dynamic> json) fromJson,
) {
  return Isolate.run(() => decodeJsonList(json, fromJson));
}
