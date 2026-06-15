import 'package:preference_store/src/preference_store.dart';
import 'package:preference_store/src/shared_preferences_store.dart';

/// Creates a new [PreferenceStore] instance.
///
/// Usage:
/// ```dart
/// final store = PreferenceStoreFactory().create();
/// ```
///
/// Consumers receive a [PreferenceStore] and never see the concrete
/// implementation.
class PreferenceStoreFactory {
  const PreferenceStoreFactory();

  PreferenceStore create() {
    return SharedPreferencesStore();
  }
}
