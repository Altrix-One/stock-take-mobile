class AppConfig {
  static const String clientId = 'pijppl7q46';
  static const String baseUrl = 'https://dev14-csf-tz.aakvaerp.com';
  static const String redirectUri = 'stockcount://oauth2redirect';
  static const String tokenEndpoint =
      '/api/method/frappe.integrations.oauth2.get_token';
  static const String userInfoEndpoint =
      '/api/method/frappe.integrations.oauth2.openid_profile';
}
