part of 'bid_bloc.dart';

@freezed
class BidState with _$BidState {
  const factory BidState.initial({
    /// BidEvent.refreshBids, BidEvent.nextBids
    @Default(VarStatus()) VarStatus bidsStatus,
    @Default([]) List<BidModel> bids,
    @Default(1) int bidsPage,
    @Default(10) int bidsPageSize,
    @Default(true) bool bidsHasNext,
    BidStateType? bidState,
    String? bidsForemanId,
    String? workerId,
    String? operatorId,
    DateTime? bidsStartDate,
    DateTime? bidsEndDate,
    String? bidsRegionId,
    String? bidsCropId,

    /// BidEvent.Bid
    @Default(VarStatus()) VarStatus bidStatus,
    @Default(BidModel()) BidModel bid,

    /// BidEvent.cancelBid
    @Default(VarStatus()) VarStatus cancelBidStatus,

    /// BidEvent.updateWorker
    @Default(VarStatus()) VarStatus updateWorkerStatus,

    /// Archives
    @Default(VarStatus()) VarStatus archiveStatus,
    @Default([]) List<ArchiveModel> archives,
    @Default(ArchiveModel()) ArchiveModel currentArchiveUpload,
  }) = _Initial;
}
