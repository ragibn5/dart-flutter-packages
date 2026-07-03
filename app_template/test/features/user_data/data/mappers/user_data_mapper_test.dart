// ignore_for_file: lines_longer_than_80_chars

import 'package:app_template/features/user_data/data/mappers/user_data_mapper.dart';
import 'package:app_template/features/user_data/data/models/user_data_dto.dart';
import 'package:app_template/features/user_data/domain/models/user_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const dto = UserDataDTO(id: 'id', name: 'Ragib');

  final entity = UserData(id: dto.id, name: dto.name);

  late UserDataMapper userDataMapper;

  setUp(() {
    userDataMapper = UserDataMapper();
  });

  test('Should encode to correct domain model', () {
    final domainModel = userDataMapper.convertDataToDomain(dto);
    expect(domainModel.id, dto.id);
    expect(domainModel.name, dto.name);
  });

  test('Should decode to correct data model', () {
    final dataModel = userDataMapper.convertDomainToData(entity);
    expect(dataModel.id, entity.id);
    expect(dataModel.name, entity.name);
  });
}
