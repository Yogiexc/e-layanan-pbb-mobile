class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://elayanan-surakarta-production.up.railway.app/api/v1',
  );

  // False = langsung tersambung ke live backend Railway
  static const bool useMockData = bool.fromEnvironment(
    'USE_MOCK_DATA',
    defaultValue: false,
  );
}
