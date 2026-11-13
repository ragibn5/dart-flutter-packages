abstract interface class DataToDomainConverter<DataModel, DomainModel> {
  DomainModel convertDataToDomain(DataModel dataModel);
}
