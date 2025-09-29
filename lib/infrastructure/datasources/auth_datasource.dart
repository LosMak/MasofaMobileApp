import 'package:api_client_dictionaries/api_client_dictionaries.dart';
import 'package:api_client_identity/api_client_identity.dart';
import 'package:dala_ishchisi/domain/facades/auth_facade.dart';
import 'package:dala_ishchisi/domain/models/meta_model.dart';
import 'package:dala_ishchisi/domain/models/user_info_model.dart';
import 'package:dala_ishchisi/infrastructure/mapper/meta_mapper.dart';
import 'package:dala_ishchisi/infrastructure/mapper/user_mapper.dart';
import 'package:dala_ishchisi/infrastructure/services/cache/auth_cache.dart';
import 'package:dala_ishchisi/infrastructure/services/http/services/dictionaries_service.dart';
import 'package:dala_ishchisi/infrastructure/services/http/services/identity_service.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: AuthFacade)
class AuthDatasource implements AuthFacade {
  final IdentityService _identity;
  final DictionariesService _dictionaries;
  final AuthCache _cache;

  const AuthDatasource(
    this._cache,
    this._identity,
    this._dictionaries,
  );

  @override
  Future<Either<dynamic, String>> login({
    required String username,
    required String password,
  }) async {
    final client = _identity
        .client(requiredToken: false, requiredRemote: true)
        .getAccountApi();
    try {
      final model = LoginAndPasswordViewModelModel(
        (b) => b
          ..password = password
          ..userName = username,
      );
      final response = await client.identityAccountLoginByLoginPasswordPost(
        loginAndPasswordViewModelModel: model,
      );

      return right(response.data!);
    } catch (e) {
      return left(e);
    }
  }

  @override
  Future<Either<dynamic, UserInfoModel>> userInfo({
    required bool requiredRemote,
  }) async {
    final client = _identity
        .client(requiredToken: true, requiredRemote: true)
        .getAccountApi();

    try {
      final response = await client.identityAccountGetProfileInfoPost();
      final result =
          UserMapper.transform<UserInfoModel, ProfileInfoViewModelModel>(
              response.data);
      return right(result);
    } catch (e) {
      return left(e);
    }
  }

  @override
  Future<Either<dynamic, MetaModel>> meta({
    required bool requiredRemote,
  }) async {
    final client = _dictionaries.client(
        requiredToken: true, requiredRemote: requiredRemote);

    try {
      final regionsResponse =
          await client.getRegionApi().dictionariesRegionGetByQueryPost();
      final regions = MetaMapper.transformList<RegionModel, TypeModel>(
        regionsResponse.data,
      );

      final cropsResponse =
          await client.getCropApi().dictionariesCropGetByQueryPost();
      final crops = MetaMapper.transformList<CropModel, TypeModel>(
        cropsResponse.data,
      );

      final bidStateResponse =
          await client.getBidStateApi().dictionariesBidStateGetByQueryPost();
      final bidStates = MetaMapper.transformList<BidStateModel, TypeModel>(
        bidStateResponse.data,
      );

      final bidTypesResponse =
          await client.getBidTypeApi().dictionariesBidTypeGetByQueryPost();
      final bidTypes = MetaMapper.transformList<BidTypeModel, TypeModel>(
        bidTypesResponse.data,
      );

      final contentsResponse = await client
          .getBidContentApi()
          .dictionariesBidContentGetByQueryPost();
      final contents = MetaMapper.transformList<BidContentModel, TypeModel>(
        contentsResponse.data,
      );

      final diseaseResponse =
          await client.getDiseaseApi().dictionariesDiseaseGetByQueryPost();
      final diseases = MetaMapper.transformList<DiseaseModel, CropTypeModel>(
        diseaseResponse.data,
      );

      final pestsResponse =
          await client.getPesticideApi().dictionariesPesticideGetByQueryPost();
      final pests = MetaMapper.transformList<PesticideModel, CropTypeModel>(
        pestsResponse.data,
      );

      final soilTypesResponse =
          await client.getSoilTypeApi().dictionariesSoilTypeGetByQueryPost();
      final soilTypes = MetaMapper.transformList<SoilTypeModel, TypeModel>(
        soilTypesResponse.data,
      );

      final wateringTypesResponse = await client
          .getWaterResourceApi()
          .dictionariesWaterResourceGetByQueryPost();
      final wateringTypes =
          MetaMapper.transformList<WaterResourceModel, TypeModel>(
        wateringTypesResponse.data,
      );

      final userTypesResourse =
          await client.getPersonApi().dictionariesPersonGetByQueryPost();
      final userTypes = MetaMapper.transformList<PersonModel, TypeModel>(
        userTypesResourse.data,
      );

      final model = MetaModel(
        regions: regions,
        crops: crops,
        bidStates: bidStates,
        bidTypes: bidTypes,
        contents: contents,
        diseases: diseases,
        pests: pests,
        soilTypes: soilTypes,
        wateringTypes: wateringTypes,
        userTypes: userTypes,
      );
      return right(model);
    } catch (e) {
      return left(e);
    }
  }

  @override
  Future<Either<dynamic, void>> logout() async {
    await _cache.clear();
    return right(null);
  }
}
