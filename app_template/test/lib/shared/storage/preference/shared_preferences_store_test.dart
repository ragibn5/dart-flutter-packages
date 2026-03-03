// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: avoid_redundant_argument_values

import 'package:app_template/shared/storage/preference/shared_preferences_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferencesAsync extends Mock
    implements SharedPreferencesAsync {}

void main() {
  late MockSharedPreferencesAsync mockPrefs;
  late SharedPreferencesStore store;

  setUp(() {
    mockPrefs = MockSharedPreferencesAsync();
    store = SharedPreferencesStore(mockPrefs);
  });

  group('Getters', () {
    test('getBool delegates', () async {
      when(() => mockPrefs.getBool('k')).thenAnswer((_) async => true);

      final result = await store.getBool('k');

      expect(result, true);
      verify(() => mockPrefs.getBool('k')).called(1);
    });

    test('getInt delegates', () async {
      when(() => mockPrefs.getInt('k')).thenAnswer((_) async => 10);

      final result = await store.getInt('k');

      expect(result, 10);
      verify(() => mockPrefs.getInt('k')).called(1);
    });

    test('getDouble delegates', () async {
      when(() => mockPrefs.getDouble('k')).thenAnswer((_) async => 1.5);

      final result = await store.getDouble('k');

      expect(result, 1.5);
      verify(() => mockPrefs.getDouble('k')).called(1);
    });

    test('getString delegates', () async {
      when(() => mockPrefs.getString('k')).thenAnswer((_) async => 'hello');

      final result = await store.getString('k');

      expect(result, 'hello');
      verify(() => mockPrefs.getString('k')).called(1);
    });

    test('getStringList delegates', () async {
      when(
        () => mockPrefs.getStringList('k'),
      ).thenAnswer((_) async => ['a', 'b']);

      final result = await store.getStringList('k');

      expect(result, ['a', 'b']);
      verify(() => mockPrefs.getStringList('k')).called(1);
    });

    test('getStringSet converts list to set', () async {
      when(
        () => mockPrefs.getStringList('k'),
      ).thenAnswer((_) async => ['a', 'b', 'a']);

      final result = await store.getStringSet('k');

      expect(result, {'a', 'b'});
    });

    test('getKeys delegates', () async {
      when(
        () => mockPrefs.getKeys(allowList: null),
      ).thenAnswer((_) async => {'a', 'b'});

      final result = await store.getKeys();

      expect(result, {'a', 'b'});
      verify(() => mockPrefs.getKeys(allowList: null)).called(1);
    });

    test('containsKey delegates', () async {
      when(() => mockPrefs.containsKey('k')).thenAnswer((_) async => true);

      final result = await store.containsKey('k');

      expect(result, true);
      verify(() => mockPrefs.containsKey('k')).called(1);
    });
  });

  group('Setters', () {
    test('setBool delegates', () async {
      when(() => mockPrefs.setBool('k', true)).thenAnswer((_) async {});

      await store.setBool('k', true);

      verify(() => mockPrefs.setBool('k', true)).called(1);
    });

    test('setInt delegates', () async {
      when(() => mockPrefs.setInt('k', 1)).thenAnswer((_) async {});

      await store.setInt('k', 1);

      verify(() => mockPrefs.setInt('k', 1)).called(1);
    });

    test('setDouble delegates', () async {
      when(() => mockPrefs.setDouble('k', 2.5)).thenAnswer((_) async {});

      await store.setDouble('k', 2.5);

      verify(() => mockPrefs.setDouble('k', 2.5)).called(1);
    });

    test('setString delegates', () async {
      when(() => mockPrefs.setString('k', 'v')).thenAnswer((_) async {});

      await store.setString('k', 'v');

      verify(() => mockPrefs.setString('k', 'v')).called(1);
    });

    test('setStringList delegates', () async {
      when(() => mockPrefs.setStringList('k', ['a'])).thenAnswer((_) async {});

      await store.setStringList('k', ['a']);

      verify(() => mockPrefs.setStringList('k', ['a'])).called(1);
    });

    test('setStringSet converts set to list', () async {
      when(() => mockPrefs.setStringList('k', any())).thenAnswer((_) async {});

      await store.setStringSet('k', {'a', 'b'});

      verify(() => mockPrefs.setStringList('k', any())).called(1);
    });
  });

  group('Remove', () {
    test('remove delegates', () async {
      when(() => mockPrefs.remove('k')).thenAnswer((_) async {});

      await store.remove('k');

      verify(() => mockPrefs.remove('k')).called(1);
    });

    test('removeAll delegates to clear', () async {
      when(() => mockPrefs.clear(allowList: null)).thenAnswer((_) async {});

      await store.removeAll();

      verify(() => mockPrefs.clear(allowList: null)).called(1);
    });
  });
}
