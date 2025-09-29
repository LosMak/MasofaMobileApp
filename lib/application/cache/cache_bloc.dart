import 'package:bloc/bloc.dart';
import 'package:dala_ishchisi/domain/facades/cache_facade.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'cache_event.dart';
part 'cache_state.dart';
part 'cache_bloc.freezed.dart';

@Injectable()
class CacheBloc extends Bloc<CacheEvent, CacheState> {
  final CacheFacade _cache;
  CacheBloc(this._cache) : super(_Initial()) {
    on<_GetSize>(_onGetSize);
    on<_DeleteCache>(_onDeleteCache);
  }

  Future<void> _onGetSize(_GetSize event, Emitter<CacheState> emit) async {
    emit(const CacheState.loading());

    final totalSizeInBytes = await _cache.getSize();

    final totalSizeInMB =
        double.tryParse((totalSizeInBytes / 1024 / 1024).toStringAsFixed(2));

    if (totalSizeInMB != null) {
      emit(CacheState.success(size: totalSizeInMB));
    } else {
      emit(const CacheState.success(size: 0));
    }
  }

  Future<void> _onDeleteCache(
      _DeleteCache event, Emitter<CacheState> emit) async {
    emit(const CacheState.loadingOnDelete());
    await _cache.deleteAll();
    emit(const CacheState.success());
  }
}
