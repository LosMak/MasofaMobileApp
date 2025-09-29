import 'package:dala_ishchisi/domain/models/user_model.dart';
import 'package:dartz/dartz.dart';

abstract class UserFacade {
  Future<Either<dynamic, List<UserModel>>> users(
    String parentId, {
    required bool requiredRemote,
  });
}
