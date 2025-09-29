import 'package:dala_ishchisi/domain/models/bid_model.dart';
import 'package:dala_ishchisi/domain/models/template_model.dart';
import 'package:dala_ishchisi/domain/models/user_info_model.dart';
import 'package:dartz/dartz.dart';

abstract class TemplateFacade {
  Future<Either<dynamic, TemplateModel>> template(
    String cropId, {
    required bool requiredRemote,
  });

  Future<Either<dynamic, void>> deleteTemplate(String bidId);

  Future<Either<dynamic, void>> uploadTemplateByBid(
    BidModel bid, {
    Function(int sent, int total)? onSendProgress,
  });

  Future<Either<dynamic, void>> uploadTemplate(
    BidModel bid,
    TemplateModel template, {
    Function(int sent, int total)? onSendProgress,
  });

  // To test zip file details | not show in release
  Future<Either<dynamic, void>> shareTemplate(
    BidModel bid,
    TemplateModel template,
  );

  Future<Either<dynamic, TemplateModel>> templateCache(String bidId);

  Future<Either<dynamic, void>> putTemplateCache(
    UserInfoModel user,
    BidModel bid,
    TemplateModel template,
  );
}
