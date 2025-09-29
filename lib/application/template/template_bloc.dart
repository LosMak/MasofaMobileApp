import 'package:bloc/bloc.dart';
import 'package:dala_ishchisi/common/constants/app_globals.dart';
import 'package:dala_ishchisi/domain/models/bid_model.dart';
import 'package:dala_ishchisi/domain/models/user_info_model.dart';
import 'package:dala_ishchisi/infrastructure/services/cache/location_cache.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

import '../../domain/facades/template_facade.dart';
import '../../domain/models/template_model.dart';
import '../var_status.dart';

part 'template_bloc.freezed.dart';
part 'template_event.dart';
part 'template_state.dart';

@Injectable()
class TemplateBloc extends Bloc<TemplateEvent, TemplateState> {
  final TemplateFacade _facade;
  final LocationCache _cache;

  TemplateBloc(this._facade, this._cache)
      : super(const TemplateState.initial()) {
    on<_Template>(_onTemplate);
    on<_DeleteTemplate>(_onDeleteTemplate);
    on<_TemplateCache>(_onTemplateCache);
    on<_PutTemplateCache>(_onPutTemplateCache);
    on<_UploadTemplate>(_onUploadTemplate);
    on<_ShareTemplate>(_onShareTemplate);
  }

  Future<void> _onTemplate(
    _Template event,
    Emitter<TemplateState> emit,
  ) async {
    emit(state.copyWith(templateStatus: VarStatus.loading()));

    final result = await _facade.template(
      event.bid.cropId,
      requiredRemote: event.requiredRemote,
    );

    result.fold(
      (l) => emit(state.copyWith(templateStatus: VarStatus.fail(l))),
      (data) {
        // ! TODO: Когда на user будут значения auto: true - убрать!
        final modifiedBlocks = data.blocks.map((block) {
          final modifiedControls = block.controls.map((control) {
            if (control.name == 'planting_date') {
              return control.copyWith(
                  resultValues: control.resultValues.isEmpty
                      ? event.bid.fieldPlantingDate
                      : control.resultValues);
            }
            return control;
          }).toList();

          final modifiedSteps = block.steps.map((step) {
            final updatedControls = step.controls.map((control) {
              if (control.name == "step_confirm") {
                return control.copyWith(resultValues: 'unchecked');
              }
              return control;
            }).toList();

            return step.copyWith(controls: updatedControls);
          }).toList();

          return block.copyWith(
              controls: modifiedControls, steps: modifiedSteps);
        }).toList();

        final result = data.copyWith(blocks: modifiedBlocks);

        emit(state.copyWith(
          templateStatus: VarStatus.success(),
          template: result,
        ));
      },
    );
  }

  Future<void> _onDeleteTemplate(
    _DeleteTemplate event,
    Emitter<TemplateState> emit,
  ) async {
    emit(state.copyWith(deleteTemplateStatus: VarStatus.loading()));

    final result = await _facade.deleteTemplate(event.bid.id);

    result.fold(
      (l) => emit(state.copyWith(deleteTemplateStatus: VarStatus.fail(l))),
      (r) {
        emit(state.copyWith(
          deleteTemplateStatus: VarStatus.success(),
          template: const TemplateModel(),
        ));
        add(TemplateEvent.template(
          bid: event.bid,
          requiredRemote: true,
        ));
      },
    );
  }

  Future<void> _onTemplateCache(
    _TemplateCache event,
    Emitter<TemplateState> emit,
  ) async {
    emit(state.copyWith(templateCacheStatus: VarStatus.loading()));

    final result = await _facade.templateCache(event.bidId);

    result.fold(
      (l) => emit(state.copyWith(templateCacheStatus: VarStatus.fail(l))),
      (r) => emit(state.copyWith(
        templateCacheStatus: VarStatus.success(),
        templateCache: r,
      )),
    );
  }

  Future<void> _onPutTemplateCache(
    _PutTemplateCache event,
    Emitter<TemplateState> emit,
  ) async {
    emit(state.copyWith(putTemplateCacheStatus: VarStatus.loading()));

    final result = await _facade.putTemplateCache(
      event.user,
      event.bid,
      event.template,
    );

    result.fold(
      (l) => emit(state.copyWith(putTemplateCacheStatus: VarStatus.fail(l))),
      (r) => emit(state.copyWith(putTemplateCacheStatus: VarStatus.success())),
    );
  }

  Future<void> _onUploadTemplate(
    _UploadTemplate event,
    Emitter<TemplateState> emit,
  ) async {
    final position = AppGlobals.position;
    if (position != null) {
      await _cache.addLocation(
        Position(
          longitude: position.longitude,
          latitude: position.latitude,
          timestamp: DateTime.now(),
          accuracy: position.accuracy,
          altitude: position.altitude,
          altitudeAccuracy: position.altitudeAccuracy,
          heading: position.heading,
          headingAccuracy: position.headingAccuracy,
          speed: position.speed,
          speedAccuracy: position.speedAccuracy,
        ),
        checkMinUpdateInterval: false,
      );
    }

    emit(state.copyWith(
      uploadTemplateStatus: VarStatus.loading(),
      uploadProgress: 0.0,
    ));

    final result = await _facade.uploadTemplate(
      event.bid,
      event.template,
      onSendProgress: (sent, total) {
        if (total > 0) {
          emit(state.copyWith(uploadProgress: sent / total));
        }
      },
    );

    result.fold(
      (l) => emit(state.copyWith(uploadTemplateStatus: VarStatus.fail(l))),
      (r) => emit(state.copyWith(uploadTemplateStatus: VarStatus.success())),
    );
  }

  Future<void> _onShareTemplate(
    _ShareTemplate event,
    Emitter<TemplateState> emit,
  ) async {
    final position = AppGlobals.position;
    if (position != null) {
      await _cache.addLocation(
        Position(
          longitude: position.longitude,
          latitude: position.latitude,
          timestamp: DateTime.now(),
          accuracy: position.accuracy,
          altitude: position.altitude,
          altitudeAccuracy: position.altitudeAccuracy,
          heading: position.heading,
          headingAccuracy: position.headingAccuracy,
          speed: position.speed,
          speedAccuracy: position.speedAccuracy,
        ),
        checkMinUpdateInterval: false,
      );
    }

    emit(state.copyWith(shareTemplateStatus: VarStatus.loading()));

    final result = await _facade.shareTemplate(event.bid, state.templateCache);

    result.fold(
      (l) => emit(state.copyWith(shareTemplateStatus: VarStatus.fail(l))),
      (r) => emit(state.copyWith(shareTemplateStatus: VarStatus.success())),
    );
  }
}
