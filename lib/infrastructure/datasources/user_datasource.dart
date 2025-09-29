import 'package:api_client_identity/api_client_identity.dart' as api;
import 'package:dala_ishchisi/domain/facades/user_facade.dart';
import 'package:dala_ishchisi/domain/models/user_model.dart';
import 'package:dala_ishchisi/infrastructure/mapper/user_mapper.dart';
import 'package:dala_ishchisi/infrastructure/services/http/services/identity_service.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: UserFacade)
class UserDatasource implements UserFacade {
  final IdentityService _identity;

  const UserDatasource(this._identity);

  @override
  Future<Either<dynamic, List<UserModel>>> users(
    String parentId, {
    required bool requiredRemote,
  }) async {
    final client = _identity
        .client(
          requiredToken: true,
          requiredRemote: requiredRemote,
        )
        .getUserApi();

    try {
      final response = await client.identityUserGetChildUsersGet();
      final result = UserMapper.transformList<UserModel, api.ProfileInfoViewModelModel>(
        response.data,
      );
      return right(result);
    } catch (e) {
      return left(e);
    }
  }
}
