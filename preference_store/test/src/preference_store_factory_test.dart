import 'package:flutter_test/flutter_test.dart';
import 'package:preference_store/src/preference_store.dart';
import 'package:preference_store/src/preference_store_factory.dart';
import 'package:preference_store/src/shared_preferences_store.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  late PreferenceStoreFactory sut;

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();

    sut = const PreferenceStoreFactory();
  });

  tearDown(() {
    SharedPreferencesAsyncPlatform.instance = null;
  });

  test('create returns a SharedPreferencesStore', () {
    final result = sut.create();

    expect(result, isA<SharedPreferencesStore>());
  });

  test('create returns an instance that implements PreferenceStore', () {
    final result = sut.create();

    expect(result, isA<PreferenceStore>());
  });
}
