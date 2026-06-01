import 'package:data_domain_converters/src/data_to_domain_converter.dart';
import 'package:data_domain_converters/src/domain_to_data_converter.dart';

abstract interface class DataDomainConverter<DataModel, DomainModel>
    implements
        DataToDomainConverter<DataModel, DomainModel>,
        DomainToDataConverter<DataModel, DomainModel> {}
