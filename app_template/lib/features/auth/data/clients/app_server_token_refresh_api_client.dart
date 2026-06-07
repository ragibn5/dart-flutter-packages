import 'package:app_template/features/auth/data/models/auth_data_dto.dart';
import 'package:app_template/features/auth/data/models/token_refresh_request.dart';
import 'package:core_models/core_models.dart';
import 'package:feature_api_client/feature_api_client.dart';

typedef AppServerTokenRefreshApiClient =
    FeatureApiClient<TokenRefreshRequest, AuthDataDTO, ServerMessage>;
