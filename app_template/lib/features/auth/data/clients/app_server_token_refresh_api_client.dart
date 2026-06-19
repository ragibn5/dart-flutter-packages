import 'package:app_template/features/auth/data/models/auth_data_dto.dart';
import 'package:app_template/features/auth/data/models/token_refresh_request.dart';
import 'package:feature_api_client/feature_api_client.dart';
import 'package:shared_models/shared_models.dart';

typedef AppServerTokenRefreshApiClient =
    FeatureApiClient<TokenRefreshRequest, AuthDataDTO, ServerMessage>;
