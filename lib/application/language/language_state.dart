part of 'language_bloc.dart';

@freezed
class LanguageState with _$LanguageState {
  const factory LanguageState.initial({
    @Default(Locale('ru')) Locale locale,
    @Default([]) List<Locale> locales,
  }) = _Initial;
}
