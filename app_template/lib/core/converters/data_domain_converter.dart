abstract interface class DataDomainConverter<DataModel, DomainModel> {
  DomainModel convertDataToDomain(DataModel dataModel);

  DataModel convertDomainToData(DomainModel domainModel);
}
