part of 'language_bloc.dart';

@freezed
class LanguageEvent with _$LanguageEvent {
  const factory LanguageEvent.getLocale({required BuildContext context}) =
      _getLocale;

  const factory LanguageEvent.setLocale(
    String locale, {
    required BuildContext context,
  }) = _setLocale;
}
