import 'package:generator_core/src/models/session_data.dart';

class SessionDataFetchResult {
  final bool isNewlyCreated;
  final SessionData sessionData;

  SessionDataFetchResult({
    required this.isNewlyCreated,
    required this.sessionData,
  });
}
