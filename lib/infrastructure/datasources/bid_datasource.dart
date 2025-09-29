import 'package:api_client_crop/api_client_crop.dart' as api;
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:dala_ishchisi/common/constants/app_globals.dart';
import 'package:dala_ishchisi/domain/facades/bid_facade.dart';
import 'package:dala_ishchisi/domain/models/bid_model.dart';
import 'package:dala_ishchisi/infrastructure/mapper/bid_mapper.dart';
import 'package:dala_ishchisi/infrastructure/services/http/services/crop_monitoring_service.dart';
import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: BidFacade)
class BidDatasource implements BidFacade {
  final CropMonitoringService _cropMonitoring;

  const BidDatasource(this._cropMonitoring);

  @override
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
  }) async {
    final client = _cropMonitoring
        .client(
          requiredToken: true,
          requiredRemote: requiredRemote,
        )
        .getBidApi();

    api.FieldFilterModel? roleFilter;
    api.FieldFilterModel? bidStateFilter;

    if (workerId != null && workerId.isNotEmpty) {
      roleFilter = api.FieldFilterModel(
        (b) => b
          ..filterField = 'workerid'
          ..filterValue = JsonObject(workerId)
          ..filterOperator = api.FilterOperatorModel.number0,
      );
    } else if (foremanId != null && foremanId.isNotEmpty) {
      roleFilter = api.FieldFilterModel(
        (b) => b
          ..filterField = 'foremanid'
          ..filterValue = JsonObject(foremanId)
          ..filterOperator = api.FilterOperatorModel.number0,
      );
    }

    if (bidState != null) {
      bidStateFilter = api.FieldFilterModel(
        (b) => b
          ..filterField = 'BidState'
          ..filterValue = JsonObject(
            BidMapper.fromBidStateTypeModelToInt(bidState),
          )
          ..filterOperator = api.FilterOperatorModel.number0,
      );
    }

    final filters = ListBuilder<api.FieldFilterModel>([
      if (roleFilter != null) roleFilter,
      if (bidStateFilter != null) bidStateFilter,
    ]);
    final model = api.BidBaseGetQueryModel(
      (b) => b
        ..filters = filters
        ..sortBy = 'Number'
        ..sort = api.SortTypeModel.number1,
    );

    try {
      final response = await client.cropMonitoringBidGetByQueryPost(
        bidBaseGetQueryModel: model,
      );
      final list = BidMapper.transformList(response.data);
      return right(list);
    } catch (e) {
      return left(e);
    }
  }

  @override
  Future<Either<dynamic, BidModel>> bid(
    String id, {
    required bool requiredRemote,
  }) async {
    final client = _cropMonitoring
        .client(
          requiredRemote: requiredRemote,
          requiredToken: true,
        )
        .getBidApi();

    try {
      final response = await client.cropMonitoringBidGetByIdIdGet(id: id);
      final result = BidMapper.transform(response.data);
      return right(result);
    } catch (e) {
      return left(e);
    }
  }

  @override
  Future<Either<dynamic, void>> updateBid(BidModel bid) async {
    final client = _cropMonitoring
        .client(
          requiredRemote: true,
          requiredToken: true,
        )
        .getBidApi();

    try {
      final bidModel = BidMapper.reverseTransform(bid);
      await client.cropMonitoringBidUpdatePut(
        bidModel: bidModel,
      );
      return right(null);
    } catch (e) {
      return left(e);
    }
  }

  @override
  Future<Either<dynamic, void>> cancel(BidModel bid) async {
    final client = _cropMonitoring
        .client(
          requiredRemote: true,
          requiredToken: true,
        )
        .getBidApi();

    try {
      final model = BidMapper.reverseTransform(bid).rebuild(
        (b) => b..bidState = api.BidStateTypeModel.number5,
      );
      await client.cropMonitoringBidUpdatePut(
        bidModel: model,
      );
      return right(null);
    } catch (e) {
      return left(e);
    }
  }

  @override
  Future<Either<dynamic, void>> updateWorker(
    BidModel bid,
    String workerId,
  ) async {
    final client = _cropMonitoring
        .client(
          requiredRemote: true,
          requiredToken: true,
        )
        .getBidApi();

    try {
      final currentBidResponse =
          await client.cropMonitoringBidGetByIdIdGet(id: bid.id);

      final currentBid = currentBidResponse.data;

      if (currentBid != null) {
        final model = currentBid.rebuild(
          (b) => b
            ..workerId = workerId
            ..bidState = b.bidState
            ..bidTypeId = b.bidTypeId ?? _emptyGuid
            ..bidTemplateId = b.bidTemplateId ?? _emptyGuid
            ..createUser = b.createUser ?? _emptyGuid
            ..lastUpdateUser = b.lastUpdateUser ?? _emptyGuid
            ..lastUpdateAt = (b.lastUpdateAt ?? DateTime.now()).toUtc()
            ..createAt =
                (b.createAt ?? b.lastUpdateAt ?? DateTime.now()).toUtc()
            ..fieldPlantingDate =
                (b.fieldPlantingDate ?? DateTime.now()).toUtc()
            ..status = b.status ?? api.StatusTypeModel.number0,
        );
        await client.cropMonitoringBidUpdatePut(
          bidModel: model,
        );
      }
      return right(null);
    } catch (e) {
      return left(e);
    }
  }

  @override
  Future<Either<dynamic, void>> updateComment(
      BidModel bid, String comment) async {
    final client = _cropMonitoring
        .client(
          requiredRemote: true,
          requiredToken: true,
        )
        .getBidApi();

    try {
      final model = BidMapper.reverseTransform(bid).rebuild(
        (b) => b..comment = comment,
      );
      await client.cropMonitoringBidUpdatePut(
        bidModel: model,
      );
      return right(null);
    } catch (e) {
      return left(e);
    }
  }

  @override
  Future<Either<dynamic, void>> updateStartDate(
    BidModel bid,
    String date,
  ) async {
    final client = _cropMonitoring
        .client(
          requiredRemote: true,
          requiredToken: true,
        )
        .getBidApi();

    try {
      final model = BidMapper.reverseTransform(bid).rebuild(
        (b) => b..startDate = _fromStringToDateTime(date),
      );
      await client.cropMonitoringBidUpdatePut(
        bidModel: model,
      );
      return right(null);
    } catch (e) {
      return left(e);
    }
  }

  @override
  Future<Either<dynamic, void>> updateEndDate(BidModel bid, String date) async {
    final client = _cropMonitoring
        .client(
          requiredRemote: true,
          requiredToken: true,
        )
        .getBidApi();

    try {
      final model = BidMapper.reverseTransform(bid).rebuild(
        (b) => b..endDate = _fromStringToDateTime(date),
      );
      await client.cropMonitoringBidUpdatePut(
        bidModel: model,
      );
      return right(null);
    } catch (e) {
      return left(e);
    }
  }

  String get _emptyGuid => '00000000-0000-0000-0000-000000000000';

  static DateTime? _fromStringToDateTime(String date) {
    final formatter = DateFormat('yyyy-MM-dd');
    return formatter.parse(date);
  }
}
