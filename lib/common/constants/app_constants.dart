abstract class AppConstants {
  const AppConstants._();

  static const String yandexApiKey = "6e61e348-993d-4a11-924c-702a0f0279f5";
  // Outdated path
  // static const String supportUrl = "https://t.me/freedomwiz";

  // New path
  // static const String supportUrl = "https://t.me/agrometeotahlil";

  // Their server (Stage)
  // static const String baseUrl = "https://gateway.stg-uz.6grain.com/api/v1";
  // static const String authUrl = "https://auth.stg-uz.6grain.com";

  // Our server (Prod)
  static const String baseUrl = 'http://185.100.234.107:30320/';

  static const String supportUrl = "https://t.me/+7rJUX6AeUoQ3NjRi";
  static const String policyUrl = "https://telegra.ph/OMMAVIY-OFERTA-12-14-2";
  static final oneIdUri = Uri(
    scheme: 'https',
    host: 'sso.egov.uz',
    path: '/sso/oauth/Authorization.do',
    queryParameters: {
      'response_type': 'one_code',
      'client_id': 'agropro_uz',
      'redirect_uri': 'https://test.farm.agropro.uz/login',
      'scope': 'qx_texnika_reestr',
      'state': 'testState',
    },
  );
}
