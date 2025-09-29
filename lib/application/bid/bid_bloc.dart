import 'package:bloc/bloc.dart';
import 'package:dala_ishchisi/domain/facades/archive_facade.dart';
import 'package:dala_ishchisi/domain/facades/bid_facade.dart';
import 'package:dala_ishchisi/domain/facades/template_facade.dart';
import 'package:dala_ishchisi/domain/models/archive_model.dart';
import 'package:dala_ishchisi/domain/models/bid_model.dart';
import 'package:dala_ishchisi/domain/models/meta_model.dart';
import 'package:dala_ishchisi/domain/models/template_model.dart';
import 'package:dala_ishchisi/infrastructure/services/http/http_service.dart';
import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../var_status.dart';

part 'bid_bloc.freezed.dart';
part 'bid_event.dart';
part 'bid_state.dart';

@Injectable()
class BidBloc extends Bloc<BidEvent, BidState> {
  final BidFacade _facade;
  final HttpService _http;
  final ArchiveFacade _archiveFacade;
  final TemplateFacade _templateFacade;

  BidBloc(
    this._facade,
    this._http,
    this._archiveFacade,
    this._templateFacade,
  ) : super(const BidState.initial()) {
    on<_RefreshBids>(_onRefreshBids);
    on<_NextBids>(_onNextBids);
    on<_Bid>(_onBid);
    on<_UpdateBidStatus>(_onUpdateBidStatus);
    on<_CancelBid>(_onCancelBid);
    on<_UpdateWorker>(_onUpdateWorker);
    on<_GetArchiveBids>(_onGetArchiveBids);
    on<_CreateArchive>(_onCreateArchive);
    on<_DeleteArchive>(_onDeleteArchive);
    on<_SendArchive>(_onSendArchive);
    on<_UpdateArchiveStatus>(_onUpdateArchiveStatus);
  }

  Future<void> _onRefreshBids(
    _RefreshBids event,
    Emitter<BidState> emit,
  ) async {
    emit(state.copyWith(
      bidsStatus: VarStatus.loading(),
      archiveStatus: VarStatus.initial(),
      bids: [],
      archives: [],
      bidsPage: 1,
      bidsPageSize: event.pageSize,
      bidState: event.bidState,
      bidsForemanId: event.foremanId,
      bidsStartDate: event.startDate,
      bidsEndDate: event.endDate,
      bidsRegionId: event.regionId,
      bidsCropId: event.cropId,
      workerId: event.workerId,
      operatorId: event.operatorId,
    ));

    if (event.clearCache) await _http.clearCache();

    final result = await _facade.bids(
      page: 1,
      size: state.bidsPageSize,
      requiredRemote: event.requiredRemote,
      bidState: state.bidState,
      foremanId: state.bidsForemanId,
      workerId: state.workerId,
      operatorId: state.operatorId,
      startDate: state.bidsStartDate,
      endDate: state.bidsEndDate,
      regionId: state.bidsRegionId,
      cropId: state.bidsCropId,
    );

    result.fold(
      (l) => emit(state.copyWith(bidsStatus: VarStatus.fail(l))),
      (r) => emit(state.copyWith(
        bidsStatus: VarStatus.success(),
        bids: r,
        bidsHasNext: r.length == state.bidsPageSize,
      )),
    );
  }

  Future<void> _onNextBids(
    _NextBids event,
    Emitter<BidState> emit,
  ) async {
    if (state.bidsStatus.isLoading || !state.bidsHasNext) return;

    emit(state.copyWith(bidsStatus: VarStatus.loading()));

    final nextPage = state.bidsPage + 1;
    final result = await _facade.bids(
      page: nextPage,
      size: state.bidsPageSize,
      requiredRemote: false,
      bidState: state.bidState,
      foremanId: state.bidsForemanId,
      workerId: state.workerId,
      operatorId: state.operatorId,
      startDate: state.bidsStartDate,
      endDate: state.bidsEndDate,
      regionId: state.bidsRegionId,
      cropId: state.bidsCropId,
    );

    result.fold(
      (l) => emit(state.copyWith(bidsStatus: VarStatus.fail(l))),
      (r) {
        emit(state.copyWith(
          bidsStatus: VarStatus.success(),
          bids: [...state.bids, ...r],
          bidsPage: nextPage,
          bidsHasNext: r.length == state.bidsPageSize,
        ));
      },
    );
  }

  Future<void> _onBid(_Bid event, Emitter<BidState> emit) async {
    emit(state.copyWith(bidStatus: VarStatus.loading(), bid: event.bid));

    if (event.clearCache) await _http.clearCache();

    final result = await _facade.bid(
      event.id,
      requiredRemote: event.requiredRemote,
    );

    result.fold(
      (l) => emit(state.copyWith(bidStatus: VarStatus.fail(l))),
      (r) => emit(state.copyWith(
        bidStatus: VarStatus.success(),
        bid: r,
      )),
    );
  }

  Future<void> _onUpdateBidStatus(
    _UpdateBidStatus event,
    Emitter<BidState> emit,
  ) async {
    if (state.bid.id.isEmpty) return;

    final updatedBid = state.bid.copyWith(
      bidState: event.bidStateType,
    );

    emit(state.copyWith(bid: updatedBid));

    await _facade.updateBid(updatedBid);
  }

  Future<void> _onCancelBid(_CancelBid event, Emitter<BidState> emit) async {
    emit(state.copyWith(cancelBidStatus: VarStatus.loading()));

    await _facade.updateComment(state.bid, event.comment);
    final result = await _facade.cancel(state.bid);

    result.fold(
      (l) => emit(state.copyWith(cancelBidStatus: VarStatus.fail(l))),
      (r) => emit(state.copyWith(cancelBidStatus: VarStatus.success())),
    );
  }

  Future<void> _onUpdateWorker(
    _UpdateWorker event,
    Emitter<BidState> emit,
  ) async {
    emit(state.copyWith(updateWorkerStatus: VarStatus.loading()));

    final result = await _facade.updateWorker(state.bid, event.workerId);

    result.fold(
      (l) => emit(state.copyWith(updateWorkerStatus: VarStatus.fail(l))),
      (r) => emit(state.copyWith(updateWorkerStatus: VarStatus.success())),
    );
  }

  Future<void> _onGetArchiveBids(
    _GetArchiveBids event,
    Emitter<BidState> emit,
  ) async {
    emit(state.copyWith(
      archives: [],
      bidState: BidStateType.archive,
      archiveStatus: VarStatus.loading(),
      bidsStatus: VarStatus.initial(),
    ));

    final result = await _archiveFacade.fetchAll();

    emit(state.copyWith(
      archives: result,
      archiveStatus: VarStatus.success(),
    ));
  }

  Future<void> _onCreateArchive(
    _CreateArchive event,
    Emitter<BidState> emit,
  ) async {
    await _archiveFacade.create(state.bid, event.template);
  }

  Future<void> _onDeleteArchive(
    _DeleteArchive event,
    Emitter<BidState> emit,
  ) async {
    await _archiveFacade.delete(event.bidId);

    final currentArchive = state.archives
        .where((archive) => archive.bid.id != event.bidId)
        .toList();

    emit(state.copyWith(archives: currentArchive));
  }

  Future<void> _onSendArchive(
    _SendArchive event,
    Emitter<BidState> emit,
  ) async {
    final targetArchive =
        state.archives.firstWhere((archive) => archive.bid.id == event.bid.id);

    final result = await _templateFacade.uploadTemplateByBid(
      event.bid,
      onSendProgress: (sent, total) {
        final archive = targetArchive.copyWith(
          progress: sent / total,
          status: ArchiveSendStatus.loading,
        );

        if (total > 0) {
          emit(state.copyWith(currentArchiveUpload: archive));
        } else if (total == 100) {
          emit(state.copyWith(archiveStatus: VarStatus.success()));
        }
      },
    );

    final newBid = await _facade.bid(event.bid.id, requiredRemote: true);

    final bids = state.bids.where((bid) => bid.id != event.bid.id).toList();

    final updatedArchive = state.currentArchiveUpload.copyWith(
      status: ArchiveSendStatus.sent,
      progress: 100.0,
      bid: newBid.getOrElse(() => event.bid),
    );

    final updatedArchives = List<ArchiveModel>.from(state.archives);

    final archiveIndex =
        updatedArchives.indexWhere((e) => e.id == updatedArchive.id);

    if (archiveIndex != -1) {
      updatedArchives[archiveIndex] = updatedArchive;
    }

    result.fold(
      (l) {
        if (l is DioException) {
          final statusCode = l.response?.statusCode;

          if (statusCode != null && statusCode == 409) {
            _archiveFacade.updateStatus(updatedArchive);

            return emit(state.copyWith(
              archiveStatus: VarStatus.success(),
              bidStatus: VarStatus.initial(),
              bids: bids,
              archives: updatedArchives,
              currentArchiveUpload: updatedArchive,
            ));
          }
        }

        final currentArchiveUpload = state.currentArchiveUpload.copyWith(
          status: ArchiveSendStatus.unsent,
          progress: 0.0,
        );

        emit(state.copyWith(
          archiveStatus: VarStatus.fail(l),
          currentArchiveUpload: currentArchiveUpload,
        ));
      },
      (r) {
        _archiveFacade.updateStatus(updatedArchive);

        emit(state.copyWith(
          archiveStatus: VarStatus.success(),
          bidStatus: VarStatus.initial(),
          bids: bids,
          archives: updatedArchives,
          currentArchiveUpload: updatedArchive,
        ));
      },
    );
  }

  Future<void> _onUpdateArchiveStatus(
    _UpdateArchiveStatus event,
    Emitter<BidState> emit,
  ) async {
    final archives = state.archives.map(
      (e) {
        if (e.id == event.bid.id) {
          return e.copyWith(
            status: ArchiveSendStatus.sent,
            progress: 100,
          );
        }
        return e;
      },
    ).toList();

    final archive =
        archives.where((e) => e.bid.id == event.bid.id).singleOrNull;
    if (archive != null) {
      await _archiveFacade.updateStatus(archive);
    }

    emit(state.copyWith(archives: archives));
  }
}
