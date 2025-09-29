part of 'cache_bloc.dart';

@freezed
class CacheEvent with _$CacheEvent {
  const factory CacheEvent.getSize() = _GetSize;
  const factory CacheEvent.deleteCache() = _DeleteCache;
}
