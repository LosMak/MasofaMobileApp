import 'package:bloc/bloc.dart';
import 'package:dala_ishchisi/common/constants/app_globals.dart';
import 'package:dala_ishchisi/infrastructure/services/cache/app_cache.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'language_bloc.freezed.dart';
part 'language_event.dart';
part 'language_state.dart';

/// This is to manage localization. There are uz/ru locales now. Checkup assets/tr/
///
/// Examples:
/// [to wrap BlocProvider] and [to get current locale]
/// ```dart
/// BlocProvider(
///    create: (_) => di<LanguageBloc>()
///       ..add(LanguageEvent.getLocale(context: context))
/// ),
/// ```
/// [to show locale in UI with BlocBuilder]
/// ```dart
/// BlocBuilder<LanguageBloc, LanguageState>(
///    builder: (context, state) {
///      return Scaffold(
///        appBar: AppBar(title: Text('${state.locale}')),
///      );
///    },
/// );
/// ```
/// [set locale]
/// ```dart
/// context
///    .read<LanguageBloc>()
///    .add(LanguageEvent.setLocale('uz', context: context));
/// ```
@Injectable()
class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  final AppCache _appCache;

  LanguageBloc(this._appCache) : super(const LanguageState.initial()) {
    on<_getLocale>(_onGetLocale);
    on<_setLocale>(_onSetLocale);
  }

  void _onGetLocale(_getLocale event, Emitter<LanguageState> emit) {
    emit(state.copyWith(locales: event.context.supportedLocales));

    if (_appCache.locale.isEmpty) return;

    AppGlobals.lang = _appCache.locale;
    emit(state.copyWith(locale: Locale(_appCache.locale)));
    event.context.setLocale(Locale(_appCache.locale));
  }

  Future<void> _onSetLocale(
    _setLocale event,
    Emitter<LanguageState> emit,
  ) async {
    AppGlobals.lang = event.locale;
    emit(state.copyWith(locale: Locale(event.locale)));
    event.context.setLocale(Locale(event.locale));
    await _appCache.setLocale(event.locale);
  }
}
