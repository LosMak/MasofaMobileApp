part of 'region_bloc.dart';

@freezed
class RegionState with _$RegionState {
  const factory RegionState.initial() = _Initial;
  const factory RegionState.loading() = _Loading;
  const factory RegionState.regions({
    @Default([]) List<RegionModel> regions,
    @Default({}) Map<String, String> cachedRegions,
    @Default([]) List<DownloadStatusModel> progress,
  }) = _Regions;

  const factory RegionState.cacheRegion({
    required String path,
  }) = _CacheRegion;

  const factory RegionState.failed() = _Failed;
}
