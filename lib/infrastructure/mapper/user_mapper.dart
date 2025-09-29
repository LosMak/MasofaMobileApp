import 'package:api_client_identity/api_client_identity.dart' as api;
import 'package:built_collection/built_collection.dart';
import 'package:dala_ishchisi/domain/models/user_info_model.dart';
import 'package:dala_ishchisi/domain/models/user_model.dart';

class UserMapper {
  static TARGET transform<TARGET, SOURCE>(SOURCE? model) {
    if (model == null) {
      if (TARGET == UserInfoModel) return const UserInfoModel() as TARGET;
      if (TARGET == UserModel) return const UserModel() as TARGET;
      throw UnimplementedError('Null model mapping not supported for $TARGET');
    }

    if (model is api.ProfileInfoViewModelModel) {
      if (TARGET == UserInfoModel) {
        final source = model;
        return UserInfoModel(
          email: source.email ?? '',
          id: source.id ?? '',
          role: _toRoles(source.roles),
        ) as TARGET;
      } else if (TARGET == UserModel) {
        final source = model;
        return UserModel(
          id: source.id ?? '',
          name: source.userName ?? '',
        ) as TARGET;
      }
    }

    throw UnimplementedError('No mapping from ${model.runtimeType} to $TARGET');
  }

  static List<TARGET> transformList<TARGET, SOURCE>(BuiltList<SOURCE>? list) {
    if (list == null) {
      return [];
    }
    return list.map<TARGET>(transform).toList();
  }

  static List<UserRole> _toRoles(BuiltList<String>? roles) {
    if (roles == null) {
      return [UserRole.worker];
    }
    return roles.map((e) => _fromStringToRole(e)).toList();
  }

  static UserRole _fromStringToRole(String? role) {
    if (role == null) {
      return UserRole.worker;
    }
    final data = role.toLowerCase();
    return switch (data) {
      'worker' => UserRole.worker,
      'foreman' => UserRole.foreman,
      'admin' => UserRole.admin,
      'operator' => UserRole.operator,
      _ => UserRole.worker
    };
  }
}
