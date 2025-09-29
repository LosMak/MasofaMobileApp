part of 'region_bloc.dart';

@freezed
class RegionEvent with _$RegionEvent {
  const factory RegionEvent.fetchRegions() = _FetchRegions;
  const factory RegionEvent.download({required String regionId}) = _Download;
  const factory RegionEvent.delete({required String regionId}) = _Delete;
  const factory RegionEvent.cancelDownload({required String regionId}) =
      _CancelDownload;
  const factory RegionEvent.fetchCacheRegion({required String regionId}) =
      _FetchCacheRegion;

  const factory RegionEvent.listenProgress() = _ListenProgress;
}
