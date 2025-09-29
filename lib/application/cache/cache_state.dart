part of 'cache_bloc.dart';

@freezed
class CacheState with _$CacheState {
  const factory CacheState.initial() = _Initial;
  const factory CacheState.loading() = _Loading;
  const factory CacheState.loadingOnDelete() = _LoadingOnDelete;
  const factory CacheState.success({@Default(0.0) double size}) = _Success;
  const factory CacheState.failed(dynamic error) = _Failed;
}
