import 'package:dala_ishchisi/domain/models/meta_model.dart';
import 'package:dala_ishchisi/domain/models/user_info_model.dart';
import 'package:dartz/dartz.dart';

abstract class AuthFacade {
  Future<Either<dynamic, String>> login({
    required String username,
    required String password,
  });

  Future<Either<dynamic, UserInfoModel>> userInfo({
    required bool requiredRemote,
  });

  Future<Either<dynamic, MetaModel>> meta({
    required bool requiredRemote,
  });

  Future<Either<dynamic, void>> logout();
}
