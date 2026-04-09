class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'AGROVERSE_API_BASE_URL',
    defaultValue: 'https://agroverse-1fed.onrender.com',
  );

  static const String apiKey = String.fromEnvironment(
    'AGROVERSE_API_KEY',
    defaultValue: 'myAgroversePrivateKey2026',
  );

  static String get resolvedApiBaseUrl {
    if (apiBaseUrl.isNotEmpty) {
      return apiBaseUrl;
    }
    return 'https://agroverse-1fed.onrender.com';
  }
}
