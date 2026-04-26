class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue:
        'https://xnyhzyvigazofjoozuub.supabase.co/functions/v1',
  );

  static const Duration requestTimeout = Duration(seconds: 180);
}
