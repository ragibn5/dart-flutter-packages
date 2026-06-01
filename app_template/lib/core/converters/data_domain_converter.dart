import 'package:app_template/core/converters/data_to_domain_converter.dart';
import 'package:app_template/core/converters/domain_to_data_converter.dart';

abstract interface class DataDomainConverter<DataModel, DomainModel>
    implements
        DataToDomainConverter<DataModel, DomainModel>,
        DomainToDataConverter<DataModel, DomainModel> {}
