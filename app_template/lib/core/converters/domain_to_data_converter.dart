abstract interface class DomainToDataConverter<DataModel, DomainModel> {
  DataModel convertDomainToData(DomainModel domainModel);
}
