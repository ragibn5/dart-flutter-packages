// ignore_for_file: lines_longer_than_80_chars

import 'package:app_template/features/user_data/data/models/user_data_dto.dart';
import 'package:app_template/features/user_data/domain/entities/user_data.dart';
import 'package:app_template/features/user_data/domain/repositories/user_data_repository.dart';
import 'package:app_template/features/user_data/domain/services/user_data_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockUserDataRepository extends Mock implements UserDataRepository {}

void main() {
  const uid = 'ragib';
  const dto = UserDataDTO(id: uid, name: 'Ragib');

  final entity = UserData(id: dto.id, name: dto.name);

  late _MockUserDataRepository mockUserDataRepository;

  late UserDataServiceImpl sut;

  setUpAll(() {
    registerFallbackValue(dto);
    registerFallbackValue(entity);
  });

  setUp(() {
    mockUserDataRepository = _MockUserDataRepository();

    sut = UserDataServiceImpl(mockUserDataRepository);
  });

  test(
    '`getUserData` should call repository with correct user id and return dto',
    () async {
      when(
        () => mockUserDataRepository.getUserData(uid),
      ).thenAnswer((_) async => entity);

      final result = await sut.getUserData(uid);

      expect(result, entity);
      verify(() => mockUserDataRepository.getUserData(uid)).called(1);
    },
  );

  test(
    '`setUserData` should call repository.setUserData with the given entity',
    () async {
      when(
        () => mockUserDataRepository.setUserData(entity),
      ).thenAnswer((_) async {});

      await sut.setUserData(entity);

      verify(() => mockUserDataRepository.setUserData(entity)).called(1);
    },
  );

  test(
    '`removeUserData` should call dao.delete with a list containing given id',
    () async {
      when(
        () => mockUserDataRepository.removeUserData(uid),
      ).thenAnswer((_) async {});

      await sut.removeUserData(uid);

      verify(() => mockUserDataRepository.removeUserData(uid)).called(1);
    },
  );
}
