part of 'bid_bloc.dart';

@freezed
class BidEvent with _$BidEvent {
  const factory BidEvent.refreshBids({
    @Default(false) bool clearCache,
    @Default(false) bool requiredRemote,
    BidStateType? bidState,
    String? foremanId,
    String? workerId,
    String? operatorId,
    @Default(10) int pageSize,
    DateTime? startDate,
    DateTime? endDate,
    String? regionId,
    String? cropId,
  }) = _RefreshBids;

  const factory BidEvent.nextBids() = _NextBids;

  const factory BidEvent.updateBidStatus({
    @Default(BidStateType.none) BidStateType bidStateType,
    @Default(BidModel()) BidModel bid,
  }) = _UpdateBidStatus;

  const factory BidEvent.bid({
    @Default(false) bool clearCache,
    @Default(false) bool requiredRemote,
    @Default(BidModel()) BidModel bid,
    required String id,
  }) = _Bid;

  const factory BidEvent.cancelBid({
    required String id,
    required String comment,
  }) = _CancelBid;

  const factory BidEvent.updateWorker({
    required String bidId,
    required String workerId,
  }) = _UpdateWorker;

  const factory BidEvent.getArchiveBids() = _GetArchiveBids;

  const factory BidEvent.createArchive({
    required BidModel bid,
    required TemplateModel template,
  }) = _CreateArchive;

  const factory BidEvent.updateArchiveStatus(BidModel bid) =
      _UpdateArchiveStatus;

  const factory BidEvent.deleteArchive(String bidId) = _DeleteArchive;
  const factory BidEvent.sendArchive(BidModel bid) = _SendArchive;
}
