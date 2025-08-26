/// Configurações globais para chamadas à WeatherAPI.
///
/// A chave é injetada em tempo de execução usando `--dart-define=WEATHER_API_KEY`.
class ApiConfig {
  ApiConfig._();

  /// URL base dos endpoints oficiais da WeatherAPI.
  static const String baseUrl = 'https://api.weatherapi.com/v1';

  /// Chave da WeatherAPI fornecida via `--dart-define=WEATHER_API_KEY`.
  static const String apiKey = String.fromEnvironment(
    'WEATHER_API_KEY',
    defaultValue: 'CHANGE_ME',
  );
}

/// Define se os data sources devem usar dados estáticos ao invés da API real.
///
/// Ative com `--dart-define=USE_MOCK=true`.
const useMock = bool.fromEnvironment('USE_MOCK', defaultValue: false);
