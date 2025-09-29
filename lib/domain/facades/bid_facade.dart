import 'package:dala_ishchisi/domain/models/bid_model.dart';
import 'package:dartz/dartz.dart';

abstract class BidFacade {
  Future<Either<dynamic, List<BidModel>>> bids({
    required int page,
    required int size,
    required bool requiredRemote,
    BidStateType? bidState,
    String? foremanId,
    String? workerId,
    String? operatorId,
    DateTime? startDate,
    DateTime? endDate,
    String? regionId,
    String? cropId,
  });

  Future<Either<dynamic, BidModel>> bid(
    String id, {
    required bool requiredRemote,
  });

  Future<Either<dynamic, void>> updateBid(BidModel bid);

  Future<Either<dynamic, void>> cancel(BidModel bid);

  Future<Either<dynamic, void>> updateWorker(BidModel bid, String workerId);

  Future<Either<dynamic, void>> updateComment(BidModel bid, String comment);

  Future<Either<dynamic, void>> updateStartDate(BidModel bid, String date);

  Future<Either<dynamic, void>> updateEndDate(BidModel bid, String date);
}
