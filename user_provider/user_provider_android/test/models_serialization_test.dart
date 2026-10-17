import 'package:flutter_test/flutter_test.dart';
import 'package:user_provider_android/src/models/user_identity.dart';

void main() {
  group('UserIdentity', () {
    const identity = UserIdentity(uid: 1010123, userId: 10, appId: 10123);

    test('round-trips through JSON', () {
      expect(UserIdentity.fromJson(identity.toJson()), identity);
    });

    test('reads the uid, user id and app id', () {
      final json = <String, dynamic>{
        'uid': 1010123,
        'userId': 10,
        'appId': 10123,
      };

      expect(
        UserIdentity.fromJson(json),
        const UserIdentity(uid: 1010123, userId: 10, appId: 10123),
      );
    });

    test('reads a JSON number sent as a double', () {
      // A channel reply is decoded as JSON, where an integral number may arrive
      // as a double.
      final json = <String, dynamic>{
        'uid': 1010123.0,
        'userId': 10.0,
        'appId': 10123.0,
      };

      expect(UserIdentity.fromJson(json), identity);
    });

    test('compares by value', () {
      expect(
        identity,
        const UserIdentity(uid: 1010123, userId: 10, appId: 10123),
      );
      expect(
        identity.hashCode,
        const UserIdentity(uid: 1010123, userId: 10, appId: 10123).hashCode,
      );
      expect(
        identity,
        isNot(const UserIdentity(uid: 1010123, userId: 10, appId: 10124)),
      );
    });
  });
}
