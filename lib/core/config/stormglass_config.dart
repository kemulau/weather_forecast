// Configurações da Storm Glass API
class StormGlassConfig {
  // Base da API
  static const String baseUrl = String.fromEnvironment(
    'STORMGLASS_BASE_URL',
    defaultValue: 'https://api.stormglass.io',
  );

  // Versão da API
  static const String apiV2 = '/v2';

  // Chave da API
  static const String apiKey = String.fromEnvironment(
    'STORMGLASS_API_KEY',
    defaultValue: '',
  );

  // Fonte padrão
  static const String defaultSource = 'sg';
}
