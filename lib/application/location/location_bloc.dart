import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dala_ishchisi/common/constants/app_globals.dart';
import 'package:dala_ishchisi/common/localization/localization.dart';
import 'package:dala_ishchisi/domain/models/polygon_model.dart';
import 'package:dala_ishchisi/infrastructure/services/cache/location_cache.dart';
import 'package:dala_ishchisi/infrastructure/services/location/location_service.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

import '../var_status.dart';

part 'location_bloc.freezed.dart';
part 'location_event.dart';
part 'location_state.dart';

/// This bloc is used to get location.
///
/// Examples:
/// [Wrap BlocProvider] and [start checking location]
/// ```dart
/// BlocProvider(
///    create: (_) => di<LocationBloc>()..add(const LocationEvent.init()),
/// ),
/// ```
/// to know current location is [available] for this contour
/// ```dart
/// context.read<LocationBloc>().add(LocationEvent.available(contour));
/// ```
/// [show with BlocBuilder]
/// ```dart
/// return BlocBuilder<LocationBloc, LocationState>(
///    builder: (context, state) {
///      return Scaffold(
///        body: Center(
///          child: Text(
///            "${state.statusPosition.isSuccess}:${state.position}"
///            "\n${state.statusAvailable.isSuccess}",
///          ),
///        ),
///      );
///    },
/// );
/// ```
@Injectable()
class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationService _locationService;
  final LocationCache _cache;

  LocationBloc(this._locationService, this._cache)
      : super(const LocationState.initial()) {
    on<_init>(_onInit);
    on<_available>(_onAvailable);
  }

  Future<void> _onInit(_init event, Emitter<LocationState> emit) async {
    if (state.statusPosition.isLoading || state.statusAvailable.isSuccess) {
      return;
    }

    emit(state.copyWith(statusPosition: VarStatus.loading()));
    while (true) {
      if (await _locationService.requestPermission()) {
        break;
      }
      await _locationService.openLocationSettings();
    }
    await emit.forEach(
      _locationService.position(),
      onData: (data) {
        AppGlobals.position = data;
        _cache.addLocation(data);

        return state.copyWith(
          statusPosition: VarStatus.success(),
          position: data,
        );
      },
      onError: (error, stackTrace) {
        return state.copyWith(
          statusPosition: VarStatus.fail('$error'),
        );
      },
    );
  }

  Future<void> _onAvailable(
    _available event,
    Emitter<LocationState> emit,
  ) async {
    if (state.position != null) {
      final inside = _locationService.isInCounter(
        event.polygon,
        state.position!,
      );
      if (inside) {
        emit(state.copyWith(
          statusAvailable: VarStatus.success(),
        ));
      } else {
        final distance = _locationService.calculateDistance(
          event.polygon,
          state.position!,
        );
        if (distance != null && distance < 2000) {
          emit(state.copyWith(
            statusAvailable: VarStatus.success(),
          ));
        } else {
          if (distance == null) {
            emit(state.copyWith(
              statusAvailable: VarStatus.fail(Words.notFoundLocation.str),
            ));
          } else {
            emit(state.copyWith(
              statusAvailable: VarStatus.fail(Words.notNearLocation.str),
            ));
          }
        }
      }
    }
  }
}
