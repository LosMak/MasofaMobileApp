import 'package:bloc/bloc.dart';
import 'package:dala_ishchisi/domain/facades/region_facade.dart';
import 'package:dala_ishchisi/domain/models/download_status_model.dart';
import 'package:dala_ishchisi/domain/models/region_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'region_event.dart';
part 'region_state.dart';
part 'region_bloc.freezed.dart';

@Injectable()
class RegionBloc extends Bloc<RegionEvent, RegionState> {
  final RegionFacade _facade;
  RegionBloc(this._facade) : super(const _Initial()) {
    on<_FetchRegions>(_onFetchRegions);
    on<_Download>(_onDownload);
    on<_Delete>(_onDelete);
    on<_CancelDownload>(_onCancelDownload);
    on<_FetchCacheRegion>(_onFetchCacheRegion);
    on<_ListenProgress>(_onListenProgress);
  }
  Future<void> _onFetchRegions(_FetchRegions event, Emitter emit) async {
    emit(const RegionState.loading());

    _facade.syncRegionsCache();
    final regions = await _facade.regions();
    final cachedRegions = await _facade.regionsCache();
    regions.fold(
      (l) => emit(const RegionState.failed()),
      (r) => emit(RegionState.regions(regions: r)),
    );
    if (state is _Failed) {
      return;
    }

    if (state is _Regions) {
      cachedRegions.fold(
        (l) => emit(const RegionState.failed()),
        (r) => emit((state as _Regions).copyWith(cachedRegions: r)),
      );
    } else {
      cachedRegions.fold(
        (l) => emit(const RegionState.failed()),
        (r) => emit(RegionState.regions(cachedRegions: r)),
      );
    }
    add(const RegionEvent.listenProgress());
  }

  Future<void> _onDownload(_Download event, Emitter emit) async {
    if (event.regionId.isNotEmpty) {
      await _facade.downloadRegion(event.regionId);
    }
  }

  Future<void> _onCancelDownload(_CancelDownload event, Emitter emit) async {
    if (state is _Regions) {
      final currentState = (state as _Regions);
      final targetProgress = currentState.progress.firstWhere(
        (element) => element.filename == event.regionId,
      );
      final currentProgress = currentState.progress
          .where(
            (element) => element != targetProgress,
          )
          .toList();
      await _facade.cancelDownload(targetProgress.taskId);
      emit(currentState.copyWith(progress: currentProgress));
    }
  }

  Future<void> _onDelete(_Delete event, Emitter emit) async {
    await _facade.deleteRegionCache(event.regionId);
    if (state is _Regions) {
      final currentState = (state as _Regions);
      final newCachedRegions =
          Map.fromEntries(currentState.cachedRegions.entries.where(
        (element) => element.key != event.regionId,
      ));
      emit(currentState.copyWith(cachedRegions: newCachedRegions));
    }
  }

  Future<void> _onFetchCacheRegion(
    _FetchCacheRegion event,
    Emitter emit,
  ) async {
    emit(const RegionState.loading());
    final path = await _facade.regionCache(event.regionId);
    path.fold(
      (l) => emit(const RegionState.failed()),
      (r) => emit(RegionState.cacheRegion(path: r)),
    );
  }

  Future<void> _onListenProgress(_ListenProgress event, Emitter emit) async {
    await emit.forEach<DownloadStatusModel>(
      _facade.progressStream,
      onData: (progress) {
        final currentState = (state as _Regions);

        final currentProgress = [...currentState.progress];

        currentProgress.removeWhere((e) => e.filename == progress.filename);

        currentProgress.add(progress);

        final updatedProgress = currentProgress
            .where(
              (e) =>
                  e.status == DownloadStatus.enqueued ||
                  e.status == DownloadStatus.running,
            )
            .toList();

        if (progress.status == DownloadStatus.complete) {
          _facade.putRegionCache(progress.filename);
          return currentState.copyWith(
            progress: updatedProgress,
            cachedRegions: {progress.filename: ''},
          );
        }

        return currentState.copyWith(progress: updatedProgress);
      },
    );
  }

  @override
  Future<void> close() {
    // Закрываем подписки, контроллеры и т.д.
    _facade.dispose();

    // Обязательно вызываем super.close()
    return super.close();
  }
}
